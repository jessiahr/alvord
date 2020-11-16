defmodule Block do
  @derive Jason.Encoder
  defstruct type: nil, name: nil, value: nil, meta: %{}
  alias Alvord.Store

  def from_map(%{
        type: type,
        name: name,
        value: value,
        meta: meta
      }) do
    %Block{
      type: type,
      name: name,
      value: value,
      meta: meta
    }
  end

  def from_map(%{"name" => name, "value" => value, "type" => type, "meta" => meta}) do
    %Block{
      type: type,
      name: name,
      value: value,
      meta: meta
    }
  end

  def from_map(%{"name" => name, "type" => "attribute", "meta" => meta}) do
    %Block{
      type: "attribute",
      name: name,
      meta: meta
    }
  end

  def check_deps(
        block = %Block{
          meta: meta
        }
      ) do
    case Map.get(meta, "deps") do
      nil ->
        block

      list ->
        results =
          list
          |> Enum.map(fn dep ->
            case Store.find(dep) do
              [] ->
                IO.puts("Unable to load dependancy [#{dep}] for block [#{block.name}]")
                raise "Missing deps"

              [found_dep = %Block{}] ->
                if found_dep.type == "attribute" &&
                     (found_dep.value == nil || found_dep.value == "") do
                  IO.puts(
                    "Dependancy [#{dep}] for block [#{block.name}] is of type attribute but has no value\n\nRun alvord configure to resolve and then try again"
                  )

                  raise "Missing attribute value"
                end

                true
            end
          end)
          |> Enum.all?()
          |> if do
            block
          end
    end
  end
end
