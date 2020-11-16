defmodule Alvord.Profile do
  alias Alvord.Store

  def export do
    Store.list()
    |> Enum.map(&Block.check_deps(&1))
    |> Enum.map(&format_function(&1))
    |> Enum.concat(default_blocks())
    |> Enum.join("\n\n")
  end

  defp default_blocks do
    []
  end

  def format_function(%Block{name: name, value: value, type: "config"}) do
    "\n\nexport #{name}=\"#{value}\"\n"
  end

  def format_function(%Block{name: name, value: value, type: "alias"}),
    do: "\n\nalias #{name}=\"#{value}\""

  def format_function(%Block{name: name, value: value, type: "function"}) do
    "function #{name} {\n\n#{value}\n}"
  end

  def format_function(%Block{type: "attribute"}),
    do: ""
end
