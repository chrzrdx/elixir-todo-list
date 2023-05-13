defmodule TodoListTest do
  use ExUnit.Case

  test "add_entry, update_entry and delete_entry all work" do
    todos =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: ~D[2023-05-03], title: "get groceries"})
      |> Todo.List.add_entry(%{date: ~D[2023-05-02], title: "write journal"})
      |> Todo.List.add_entry(%{date: ~D[2023-05-05], title: "buy coconut"})
      |> Todo.List.add_entry(%{date: ~D[2023-05-03], title: "sell cat pics"})
      |> Todo.List.add_entry(%{date: ~D[2023-05-03], title: "redeem coupon"})
      |> Todo.List.add_entry(%{date: ~D[2023-05-02], title: "sing a song"})
      |> Todo.List.update_entry(6, fn _ -> %{date: ~D[2023-05-02], title: "sing a lullaby"} end)
      |> Todo.List.update_entry(3, fn _ -> %{title: "buy banana"} end)
      |> Todo.List.update_entry(3, fn _ -> %{date: ~D[2023-05-02]} end)
      |> Todo.List.update_entry(3, fn _ -> %{date: ~D[2023-05-06]} end)
      |> Todo.List.add_entry(%{date: ~D[2023-05-03], title: "jog 5km"})
      |> Todo.List.delete_entry(4)

    assert todos == %Todo.List{
             auto_id: 8,
             entries: %{
               1 => %{date: ~D[2023-05-03], id: 1, title: "get groceries"},
               2 => %{date: ~D[2023-05-02], id: 2, title: "write journal"},
               3 => %{date: ~D[2023-05-06], id: 3, title: "buy banana"},
               5 => %{date: ~D[2023-05-03], id: 5, title: "redeem coupon"},
               6 => %{date: ~D[2023-05-02], id: 6, title: "sing a lullaby"},
               7 => %{date: ~D[2023-05-03], id: 7, title: "jog 5km"}
             },
             entries_by_date: %{
               ~D[2023-05-02] => [6, 2],
               ~D[2023-05-03] => [7, 5, 1],
               ~D[2023-05-06] => [3]
             }
           }
  end

  test "Initialise a todo list with a list of entries" do
    todos =
      Todo.List.new([
        %{date: ~D[2023-05-03], title: "get groceries"},
        %{date: ~D[2023-05-03], title: "redeem coupon"},
        %{date: ~D[2023-05-02], title: "sing a song"}
      ])

    assert todos == %Todo.List{
             auto_id: 4,
             entries: %{
               1 => %{date: ~D[2023-05-03], id: 1, title: "get groceries"},
               2 => %{date: ~D[2023-05-03], id: 2, title: "redeem coupon"},
               3 => %{date: ~D[2023-05-02], id: 3, title: "sing a song"}
             },
             entries_by_date: %{~D[2023-05-02] => [3], ~D[2023-05-03] => [2, 1]}
           }
  end

  test "Todo.List implements the Collectable protocol" do
    entries = [
      %{date: ~D[2023-05-03], title: "get groceries"},
      %{date: ~D[2023-05-03], title: "redeem coupon"},
      %{date: ~D[2023-05-02], title: "sing a song"}
    ]

    todos = for entry <- entries, into: Todo.List.new(), do: entry

    assert todos == %Todo.List{
             auto_id: 4,
             entries: %{
               1 => %{date: ~D[2023-05-03], id: 1, title: "get groceries"},
               2 => %{date: ~D[2023-05-03], id: 2, title: "redeem coupon"},
               3 => %{date: ~D[2023-05-02], id: 3, title: "sing a song"}
             },
             entries_by_date: %{~D[2023-05-02] => [3], ~D[2023-05-03] => [2, 1]}
           }
  end
end
