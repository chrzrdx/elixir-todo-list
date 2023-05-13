defmodule TodoListTest do
  use ExUnit.Case
  doctest Todo.List

  test "greets the world" do
    assert Todo.List.hello() == :world
  end
end
