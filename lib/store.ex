defmodule Alvord.Store do
  require Logger
  use GenServer

  @table_name :alvord_store

  def start_link(_) do
    file_path = '#{Application.get_env(:pinger, :storage_path)}#{@table_name}'
    {:ok, _} = :dets.open_file(@table_name, type: :set, auto_save: 10_000, file: file_path)
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
    [
      %{
        type: "alias",
        name: "alvord",
        script: "/home/jessiahr/Desktop/dev/alvord/alvord"
      },
      %{
        type: :function,
        name: "show_port",
        script: """
        pid_found=$(netstat -vanp tcp | grep $1 | awk '{print $9}')
        echo '$pid_found'
        ps -p $pid_found
        """
      },
      %{
        type: :function,
        name: "clear_port",
        script: """
        pid_found=$(netstat -vanp tcp | grep $1 | awk '{print $9}')
        kill -9 $pid_found
        """
      },
      %{
        type: :alias,
        name: "mc",
        script: "iex -S mix"
      },
      %{
        type: :config,
        name: "ALVORD_RENDERED_AT",
        script: "#{DateTime.utc_now() |> DateTime.to_unix()}"
      }
    ]
    |> Enum.map(fn block ->
      block
      |> Block.from_map()
      |> push
    end)
  end
end
