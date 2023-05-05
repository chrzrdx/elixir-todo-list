defmodule TodoBasicTest do
  use ExUnit.Case
  doctest TodoBasic

  test "greets the world" do
    assert TodoBasic.hello() == :world
  end
end
