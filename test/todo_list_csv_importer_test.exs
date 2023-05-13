defmodule TodoListCsvImporterTest do
  use ExUnit.Case

  test "can import from a file" do
    todos_from_file = Todo.List.CsvImporter.import("./test/sample_todo_list.csv")

    assert todos_from_file == %Todo.List{
             auto_id: 6,
             entries: %{
               1 => %{date: ~D[2023-05-03], id: 1, title: "get groceries"},
               2 => %{date: ~D[2023-05-02], id: 2, title: "write journal"},
               3 => %{date: ~D[2023-05-05], id: 3, title: "buy coconut"},
               4 => %{date: ~D[2023-05-03], id: 4, title: "redeem coupon"},
               5 => %{date: ~D[2023-05-02], id: 5, title: "sing a song"}
             },
             entries_by_date: %{
               ~D[2023-05-02] => [5, 2],
               ~D[2023-05-03] => [4, 1],
               ~D[2023-05-05] => [3]
             }
           }
  end
end
