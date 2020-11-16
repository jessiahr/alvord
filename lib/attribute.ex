defmodule Alvord.Attribute do
  alias Alvord.Store

  def list do
    Store.list()
    |> Enum.filter(fn block ->
      block.type == "attribute"
    end)
  end

  def find([name]) do
    list()
    |> Enum.find(fn block ->
      block.name == name
    end)
  end

  def configure do
    list()
    |> Enum.filter(fn block ->
      block.value == nil
    end)
    |> Enum.map(fn block = %Block{meta: meta = %{"package" => package}} ->
      docs = meta |> Map.get("docs")
      if docs != nil, do: IO.puts(docs)

      value =
        IO.gets("#{package}.#{block.name}:\t")
        |> String.replace_suffix("\n", "")

      Map.put(block, :value, value)
      |> IO.inspect()
      |> Store.push()
      |> IO.inspect()
    end)
  end
end
