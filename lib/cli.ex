defmodule Alvord.CLI do
  alias Alvord.Profile
  alias Alvord.Store
  alias Alvord.Attribute

  def main(args \\ []) do
    Store.start_link(nil)
    route_args(args)

    Store.stop()
  end

  def route_args(["help"]), do: show_help
  def route_args(["seed"]), do: Store.seed()
  def route_args(["configure"]), do: Attribute.configure()

  def route_args(["attribute" | args]) do
    block = Attribute.find(args)

    if block != nil && block != "" do
      IO.puts(block.value)
    end
  end

  def route_args(["reset"]), do: Store.clear_all_data()

  def route_args(["export"]) do
    Profile.export()
    |> IO.puts()
  end

  def route_args(["inspect" | args]) do
    [name] = args

    Store.find(name)
    |> Jason.encode!(pretty: true)
    |> IO.puts()
  end

  def route_args(args \\ []), do: show_help

  def show_help do
    IO.puts("""
    Usage: alvord COMMAND

    Available commands:
    help\t--  shows this message
    ls\t--  list all blocks
    inspect\t--  show details of a block
    confingure\t--  configure attributes
    seed\t--  loads and enables hardcoded seeds
    export\t--  compile and output to stdIO all saved blocks

    Active blocks:
    """)

    Store.list()
    |> Enum.group_by(fn block -> block.meta |> Map.get("package") end)
    |> Enum.each(fn {package_name, blocks} ->
      IO.puts("\nPackage: #{package_name}")

      Enum.each(blocks, fn block ->
        IO.puts(
          "-- #{String.pad_trailing(block.name, 20)}#{String.pad_trailing(block.type, 10)}  [#{
            String.slice(block.value, 0..100) |> String.replace("\n", "\\n ")
          }]"
        )
      end)
    end)
  end
end
