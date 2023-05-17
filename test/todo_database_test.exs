defmodule TodoDatabaseTest do
  use ExUnit.Case
  alias Todo.Database

  setup %{test: test_name} do
    db = "db.#{to_string(test_name)}" |> String.to_atom()
    persist_db = "./db/data/test.#{to_string(test_name)}"

    database = %Database{
      db: db,
      persist_db: persist_db
    }

    {:ok, _} = Database.start(database)

    alice_todo_list_name = "alice.#{:rand.uniform()}"

    todos =
      Todo.List.new([
        %{date: ~D[2023-05-03], title: "get groceries"},
        %{date: ~D[2023-05-03], title: "redeem coupon"},
        %{date: ~D[2023-05-02], title: "sing a song"}
      ])

    Database.store(database, alice_todo_list_name, todos)

    on_exit(fn ->
      GenServer.stop(database.db, :normal)
      File.rm_rf!(Database.file_name(database, alice_todo_list_name))
    end)

    %{alice: alice_todo_list_name, database: database}
  end

  test "can read a todo list from the database", %{alice: alice, database: database} do
    assert Database.get(database, alice) == %Todo.List{
             auto_id: 4,
             entries: %{
               1 => %{date: ~D[2023-05-03], id: 1, title: "get groceries"},
               2 => %{date: ~D[2023-05-03], id: 2, title: "redeem coupon"},
               3 => %{date: ~D[2023-05-02], id: 3, title: "sing a song"}
             },
             entries_by_date: %{~D[2023-05-02] => [3], ~D[2023-05-03] => [2, 1]}
           }
  end

  test "can write a todo list to the database", %{alice: alice, database: database} do
    # need this so that we're confident that the .store cast is processed by then
    # otherwise this test fails because the new file hasn't been created yet
    Database.get(database, alice)

    assert File.exists?(Database.file_name(database, alice))
  end
end
