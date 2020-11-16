defmodule Alvord.ProfileTest do
  use ExUnit.Case
  alias Alvord.Profile
  alias Alvord.Store
  doctest Profile

  @test_alias %Block{
    type: "alias",
    name: "mc",
    value: "iex -S mix"
  }

  @test_func %Block{
    type: "function",
    name: "clear_port",
    value: """
    pid_found=$(netstat -vanp tcp | grep $1 | awk '{print $9}')
    kill -9 $pid_found
    """
  }

  @test_config %Block{
    type: "config",
    name: "ALVORD_TEST",
    value: "passed"
  }

  test "exports a alias" do
    result =
      @test_alias
      |> Profile.format_function()

    assert result == "\n\nalias mc=\"iex -S mix\""
  end

  test "exports a function" do
    result =
      @test_func
      |> Profile.format_function()

    assert result ==
             "function clear_port {\n\npid_found=$(netstat -vanp tcp | grep $1 | awk '{print $9}')\nkill -9 $pid_found\n\n}"
  end

  test "exports a config" do
    result =
      @test_config
      |> Profile.format_function()

    assert result == "\n\nexport ALVORD_TEST=\"passed\"\n"
  end

  test "exports to a bash script" do
    Store.start_link(nil)
    Store.clear_all_data()
    Store.push(@test_config)
    Store.push(@test_func)
    Store.push(@test_alias)

    assert Profile.export() ==
             "function clear_port {\n\npid_found=$(netstat -vanp tcp | grep $1 | awk '{print $9}')\nkill -9 $pid_found\n\n}\n\n\n\nexport ALVORD_TEST=\"passed\"\n\n\n\n\nalias mc=\"iex -S mix\""
  end
end
