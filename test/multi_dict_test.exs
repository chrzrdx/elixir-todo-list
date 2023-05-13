defmodule MultiDictTest do
  use ExUnit.Case

  test "key value store works" do
    multidict =
      MultiDict.new()
      |> MultiDict.add(1, :a)
      |> MultiDict.add(2, :a)
      |> MultiDict.add(3, :a)
      |> MultiDict.add(4, :a)
      |> MultiDict.add(1, :b)
      |> MultiDict.add(2, :b)
      |> MultiDict.add(3, :b)
      |> MultiDict.add(1, :c)
      |> MultiDict.delete(1, :b)
      |> MultiDict.add(1, :b)
      |> MultiDict.delete(4, :a)
      |> MultiDict.delete(4, :a)
      |> MultiDict.delete(4, :a)

    assert multidict == %{1 => [:b, :c, :a], 2 => [:b, :a], 3 => [:b, :a]}
  end
end
