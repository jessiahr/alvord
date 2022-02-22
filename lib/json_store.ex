defmodule JsonStore do
  def store_path do
    Alvord.Store.storage_path <> "/json_store"
  end

  def init do
    File.mkdir(store_path())
  end

  def read(key) do
    with {:ok, data} <- File.read(store_path() <> key),
         {:ok, result} <- Jason.decode(data) do
      {:ok, result}
    else
      _ ->
        :error
    end
  end

  def write(key, data) when is_map(data) do
    File.write(store_path() <> key, data |> Jason.encode!())
  end

  def list do
    File.ls(store_path())
  end
end
