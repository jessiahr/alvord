defmodule Alvord.Repo do
  alias Alvord.Store

  @repos [
    "git@github.com:jessiahr/alvord_packages.git"
  ]

  @spec packages_path :: <<_::64, _::_*8>>
  def packages_path do
    "#{Alvord.Store.storage_path()}/packages"
  end

  def export_package do
    unless File.exists?(packages_path) do
      File.mkdir(packages_path)
    end

    blocks =
      Store.list()
      |> Jason.encode!(pretty: true)

    contents = %{
      name: "base",
      blocks: blocks
    }

    File.write("#{packages_path}/local.json", contents, [:write])
  end

  def read_packages(path \\ "./packages/local.json") do
    with {:ok, body} <- File.read(path),
         {:ok, package} <- decode(path, body) do
      meta = %{
        repo: path,
        package: Map.get(package, "name")
      }

      blocks =
        Map.get(package, "blocks")
        |> Enum.map(fn block ->
          local_meta = Map.get(block, "meta") || %{}

          Map.put(block, "meta", Map.merge(local_meta, meta))
          |> Block.from_map()
        end)
    end
  end

  defp decode(path, body) do
    case Path.extname(path) do
      ".yaml" ->
        YamlElixir.read_from_string(body)

      ".json" ->
        Jason.decode(body)
    end
  end

  # |> Enum.map(fn block ->
  #   Block.from_map(block) |> Store.push()
  # end)

  def repo_packages do
    :ok = File.mkdir_p(packages_path)
    {:ok, files} = File.ls(packages_path)

    files
    |> Enum.map(fn file ->
      if File.dir?("#{packages_path}/#{file}") do
        File.ls!("#{packages_path}/#{file}/")
        |> Enum.filter(fn file ->
          Path.extname(file) == ".json" || Path.extname(file) == ".yaml"
        end)
        |> Enum.map(fn json_file ->
          IO.puts("#{file}/#{json_file}")
          read_packages("#{packages_path}/#{file}/#{json_file}")
        end)
        |> List.flatten()
      end
    end)
    |> List.flatten()
  end

  def pull_repo(url) do
    repo = Git.clone([url, "#{packages_path}/#{repo_uri_to_folder(url)}"])
  end

  def update_all do
    :ok = File.mkdir_p(packages_path)
    {:ok, files} = File.ls(packages_path)

    files
    |> Enum.map(fn file ->
      if File.dir?("#{packages_path}/#{file}") do
        repo = Git.new("#{packages_path}/#{file}")
        |> Git.pull(~w(--rebase origin master))
      end
    end)
    |> List.flatten()
  end

  defp repo_uri_to_folder(uri),
    do: uri |> URI.parse() |> Map.get(:path) |> String.replace("/", "_")
end
