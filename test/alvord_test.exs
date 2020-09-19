defmodule AlvordTest do
  use ExUnit.Case
  doctest Alvord

  test "greets the world" do
    assert Alvord.hello() == :world
  end
end
