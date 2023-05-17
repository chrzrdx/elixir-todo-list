defmodule TodoServerTest do
  use ExUnit.Case

  alias Todo.Database
  alias Todo.Database.Config, as: DatabaseConfig
  alias Todo.Server
  alias Todo.Server.Config, as: ServerConfig

  setup %{test: test_name} do
    db_name = "db.#{to_string(test_name)}" |> String.to_atom()
    persist_db = "./db/data/test.#{to_string(test_name)}"

    db = %DatabaseConfig{
      name: db_name,
      persist_db: persist_db
    }

    {:ok, _} = Database.start(db)

    key = "alice.#{:rand.uniform()}"
    {:ok, server_pid} = Server.start(%ServerConfig{key: key, db: db})

    on_exit(fn ->
      GenServer.stop(server_pid, :normal)
      GenServer.stop(db.name, :normal)
      File.rm_rf(db.persist_db)
    end)

    %{server: server_pid}
  end

  test "All public interface functions are implemented", context do
    %{server: server} = context

    Server.add_entry(server, %{date: ~D[2023-05-03], title: "get groceries"})
    Server.add_entry(server, %{date: ~D[2023-05-02], title: "write journal"})
    Server.add_entry(server, %{date: ~D[2023-05-05], title: "buy coconut"})
    Server.add_entry(server, %{date: ~D[2023-05-03], title: "sell cat pics"})
    Server.add_entry(server, %{date: ~D[2023-05-03], title: "redeem coupon"})
    Server.add_entry(server, %{date: ~D[2023-05-02], title: "sing a song"})

    Server.update_entry(server, 6, fn _ -> %{date: ~D[2023-05-02], title: "sing a lullaby"} end)
    Server.update_entry(server, 3, fn _ -> %{title: "buy banana"} end)
    Server.update_entry(server, 3, fn _ -> %{date: ~D[2023-05-02]} end)
    Server.update_entry(server, 3, fn _ -> %{date: ~D[2023-05-06]} end)

    Server.add_entry(server, %{date: ~D[2023-05-03], title: "jog 5km"})

    Server.delete_entry(server, 4)

    assert Server.entries(server, ~D[2023-05-03]) == ["jog 5km", "redeem coupon", "get groceries"]
    assert Server.entries(server, ~D[2023-05-02]) == ["sing a lullaby", "write journal"]
    assert Server.entries(server, ~D[2023-05-05]) == []
    assert Server.entries(server, ~D[2023-05-07]) == []
  end
end
