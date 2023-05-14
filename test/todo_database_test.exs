defmodule TodoDatabaseTest do
  use ExUnit.Case
  alias Todo.Database

  setup do
    Database.start()

    alice_todo_list_name = "alice.#{:rand.uniform()}"

    todos =
      Todo.List.new([
        %{date: ~D[2023-05-03], title: "get groceries"},
        %{date: ~D[2023-05-03], title: "redeem coupon"},
        %{date: ~D[2023-05-02], title: "sing a song"}
      ])

    Database.store(alice_todo_list_name, todos)

    on_exit(fn ->
      GenServer.stop(Database, :normal)
      File.rm_rf!(Database.file_name(alice_todo_list_name))
    end)

    %{alice: alice_todo_list_name}
  end

  test "can read a todo list from the database", %{alice: alice} do
    assert Database.get(alice) == %Todo.List{
             auto_id: 4,
             entries: %{
               1 => %{date: ~D[2023-05-03], id: 1, title: "get groceries"},
               2 => %{date: ~D[2023-05-03], id: 2, title: "redeem coupon"},
               3 => %{date: ~D[2023-05-02], id: 3, title: "sing a song"}
             },
             entries_by_date: %{~D[2023-05-02] => [3], ~D[2023-05-03] => [2, 1]}
           }
  end

  test "can write a todo list to the database", %{alice: alice} do
    # need this so that we're confident that the .store cast is processed by then
    # otherwise this test fails because the new file hasn't been created yet
    Database.get(alice)

    assert File.exists?(Database.file_name(alice))
  end
end
