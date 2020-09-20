defmodule Alvord.CLI do
  alias Alvord.Profile
  alias Alvord.Store

  def main(args \\ []) do
    Store.start_link(nil)
    route_args(args)

    Store.stop()
  end

  def route_args(["help"]), do: show_help
  def route_args(["seed"]), do: Store.seed()

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
    seed\t--  loads and enables hardcoded seeds
    export\t--  compile and output to stdIO all saved blocks

    Active blocks:
    """)

    Store.list()
    |> Enum.each(fn block ->
      IO.puts("-- #{block.type}\t\t#{block.name}")
    end)
  end
end
