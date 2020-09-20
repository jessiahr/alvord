defmodule Alvord.Profile do
  alias Alvord.Store

  def export do
    Store.list()
    |> Enum.map(&format_function(&1))
    |> Enum.join("\n\n")
  end

  def format_function(%Block{name: name, script: script, type: "config"}) do
    "\n\nexport #{name}=\"#{script}\"\n"
  end

  def format_function(%Block{name: name, script: script, type: "alias"}),
    do: "\n\nalias #{name}=\"#{script}\""

  def format_function(%Block{name: name, script: script, type: "function"}) do
    "function #{name} {\n\n#{script}\n}"
  end
end
