defmodule TodoDatabaseTest do
  use ExUnit.Case
  alias Todo.Database
  alias Todo.Database.Config

  setup %{test: test_name} do
    db_name = "db.#{to_string(test_name)}" |> String.to_atom()
    persist_db = "./db/data/test.#{to_string(test_name)}"

    config = %Config{
      name: db_name,
      persist_db: persist_db
    }

    {:ok, _} = Database.start(config)

    alice_todo_list_name = "alice.#{:rand.uniform()}"

    todos =
      Todo.List.new([
        %{date: ~D[2023-05-03], title: "get groceries"},
        %{date: ~D[2023-05-03], title: "redeem coupon"},
        %{date: ~D[2023-05-02], title: "sing a song"}
      ])

    Database.store(config, alice_todo_list_name, todos)

    on_exit(fn ->
      GenServer.stop(config.name, :normal)
      File.rm_rf(config.persist_db)
    end)

    %{alice: alice_todo_list_name, config: config}
  end

  test "can read a todo list from the config", %{alice: alice, config: config} do
    # wait for 1ms for the store operation to go through
    Process.sleep(1)

    assert Database.get(config, alice) == %Todo.List{
             auto_id: 4,
             entries: %{
               1 => %{date: ~D[2023-05-03], id: 1, title: "get groceries"},
               2 => %{date: ~D[2023-05-03], id: 2, title: "redeem coupon"},
               3 => %{date: ~D[2023-05-02], id: 3, title: "sing a song"}
             },
             entries_by_date: %{~D[2023-05-02] => [3], ~D[2023-05-03] => [2, 1]}
           }
  end

  test "can write a todo list to the config", %{alice: alice, config: config} do
    # need this so that we're confident that the .store cast is processed by then
    # otherwise this test fails because the new file hasn't been created yet
    Database.get(config, alice)

    assert File.exists?(Database.file_name(config, alice))
  end
end
