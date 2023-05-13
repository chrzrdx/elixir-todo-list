defmodule Todo.List.Test do
  def test() do
    Todo.List.new()
    |> Todo.List.add_entry(%{date: ~D[2023-05-03], title: "get groceries"})
    |> Todo.List.add_entry(%{date: ~D[2023-05-02], title: "write journal"})
    |> Todo.List.add_entry(%{date: ~D[2023-05-05], title: "buy coconut"})
    |> Todo.List.add_entry(%{date: ~D[2023-05-03], title: "sell feet pics"})
    |> Todo.List.add_entry(%{date: ~D[2023-05-03], title: "redeem coupon"})
    |> Todo.List.add_entry(%{date: ~D[2023-05-02], title: "sing a song"})
    |> Todo.List.update_entry(6, fn _ -> %{date: ~D[2023-05-02], title: "sing a lullaby"} end)
    |> Todo.List.update_entry(3, fn _ -> %{title: "buy banana"} end)
    |> Todo.List.update_entry(3, fn _ -> %{date: ~D[2023-05-02]} end)
    |> Todo.List.update_entry(3, fn _ -> %{date: ~D[2023-05-06]} end)
    |> Todo.List.add_entry(%{date: ~D[2023-05-03], title: "jog 5km"})
    |> Todo.List.delete_entry(4)
  end

  def test_new_from_entries() do
    Todo.List.new([
      %{date: ~D[2023-05-03], title: "get groceries"},
      %{date: ~D[2023-05-02], title: "write journal"},
      %{date: ~D[2023-05-05], title: "buy coconut"},
      %{date: ~D[2023-05-03], title: "sell feet pics"},
      %{date: ~D[2023-05-03], title: "redeem coupon"},
      %{date: ~D[2023-05-02], title: "sing a song"}
    ])
  end

  def test_collectable() do
    entries = [
      %{date: ~D[2023-05-03], title: "get groceries"},
      %{date: ~D[2023-05-02], title: "write journal"},
      %{date: ~D[2023-05-05], title: "buy coconut"},
      %{date: ~D[2023-05-03], title: "sell feet pics"},
      %{date: ~D[2023-05-03], title: "redeem coupon"},
      %{date: ~D[2023-05-02], title: "sing a song"}
    ]

    for entry <- entries, into: Todo.List.new(), do: entry
  end
end
