defmodule TodoCacheTest do
  use ExUnit.Case

  alias Todo.Cache
  alias Todo.Cache.Config, as: CacheConfig
  alias Todo.Database.Config, as: DatabaseConfig
  alias Todo.Server

  setup %{test: test_name} do
    db_name = "db.#{to_string(test_name)}" |> String.to_atom()
    persist_db = "./db/data/test.#{to_string(test_name)}"
    cache_name = "cache.#{to_string(test_name)}" |> String.to_atom()

    config = %CacheConfig{
      name: cache_name,
      db: %DatabaseConfig{
        name: db_name,
        persist_db: persist_db
      }
    }

    {:ok, _} = Cache.start(config)

    n = 10

    Enum.each(1..n, &Cache.server_process(config, "List number #{&1}"))

    {:ok, alice} = Cache.server_process(config, "List number 1")
    {:ok, bob} = Cache.server_process(config, "List number #{n + 1}")

    Server.add_entry(alice, %{date: ~D[2023-05-03], title: "get groceries"})
    Server.add_entry(alice, %{date: ~D[2023-05-02], title: "write journal"})
    Server.add_entry(alice, %{date: ~D[2023-05-05], title: "buy coconut"})
    Server.add_entry(alice, %{date: ~D[2023-05-03], title: "sell cat pics"})

    Server.add_entry(bob, %{date: ~D[2023-05-03], title: "redeem coupon"})
    Server.add_entry(bob, %{date: ~D[2023-05-02], title: "sing a song"})

    on_exit(fn ->
      Enum.each(
        1..(n + 1),
        fn i ->
          with {:ok, server_pid} <- Cache.server_process(config, "List number #{i}") do
            GenServer.stop(server_pid, :normal)
          end
        end
      )

      GenServer.stop(config.db.name, :normal)
      File.rm_rf(config.db.persist_db)

      GenServer.stop(config.name, :normal)
    end)

    %{alice: alice, bob: bob}
  end

  test "add entry works", context do
    %{alice: alice, bob: bob} = context

    assert Server.entries(alice, ~D[2023-05-03]) == ["sell cat pics", "get groceries"]
    assert Server.entries(bob, ~D[2023-05-03]) == ["redeem coupon"]
  end

  test "no entries for an empty todo list", context do
    %{bob: bob} = context

    assert Server.entries(bob, ~D[2023-05-10]) == []
  end
end
