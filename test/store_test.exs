defmodule Alvord.StoreTest do
  use ExUnit.Case
  alias Alvord.Store
  doctest Store

  @test_alias %Block{
    type: "alias",
    name: "some_test",
    value: "iex -S mix"
  }

  setup do
    Store.start_link(nil)
    Store.clear_all_data()
    Store.push(@test_alias)
    :ok
  end

  test "saves a block" do
    assert Store.push(%Block{
             type: :alias,
             name: "mc",
             value: "iex -S mix"
           }) == :ok
  end

  test "saves a block attribute" do
    assert Store.push(%Block{
             type: :attribute,
             name: "fake.key",
             value: nil,
             meta: %{
               value: "a;lsakdjfal;kdfjalkdsjf"
             }
           }) == :ok

    Store.find("some_test")
  end

  test "gets a block" do
    assert Store.find("some_test") == [@test_alias]
  end
end
