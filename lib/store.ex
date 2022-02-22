defmodule Alvord.Store do
  require Logger
  use GenServer
  alias Alvord.Repo

  @table_name :alvord_store
  def dets_path do
    "#{storage_path}/#{@table_name}"
  end

  def storage_path do
    "#{System.user_home()}/.alvord"
  end

  def start_link(_) do
    unless File.exists?(storage_path) do
      File.mkdir(storage_path)
    end

    {:ok, _} =
      :dets.open_file(@table_name, type: :set, auto_save: 10_000, file: String.to_atom(dets_path))

    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def stop do
    :dets.close(@table_name)
  end

  def push(%Block{name: name} = block) do
    :dets.insert(@table_name, {name, Jason.encode!(block)})
  end

  def delete(name) do
    :dets.delete(@table_name, name)
  end

  def find(name) do
    :dets.lookup(@table_name, name)
    |> Enum.map(&tuple_to_struct(&1))
  end

  def list do
    :dets.match(@table_name, {:"$1", :"$2"})
    |> Enum.map(&tuple_to_struct(&1))
  end

  def clear_all_data do
    :dets.delete_all_objects(@table_name)
  end

  defp tuple_to_struct([name, block]) do
    tuple_to_struct({name, block})
  end

  defp tuple_to_struct({_name, block}) do
    Jason.decode!(block)
    |> Block.from_map()
  end

  def seed do
    Repo.repo_packages()
    |> Enum.map(fn block ->
      case find(block.name) do
        [] ->
          block
          |> Block.from_map()
          |> push
        [%Block{value: old_value, type: "attribute"}] ->
          nil

        [%Block{value: old_value}] ->
          if old_value != block.value do
            IO.puts "Imported updated block [#{block.name}]"
            block
            |> Block.from_map()
            |> push
          end
      end
    end)
  end
end
