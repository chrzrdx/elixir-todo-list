defmodule TodoCacheTest do
  use ExUnit.Case
  alias Todo.Cache
  alias Todo.Server

  setup %{test: test_name} do
    n = 10

    {:ok, cache_pid} = Cache.start(test_name)

    Enum.each(1..n, &Cache.server_process(cache_pid, "List number #{&1}"))

    {:ok, alice} = Cache.server_process(cache_pid, "List number 1")
    {:ok, bob} = Cache.server_process(cache_pid, "List number #{n + 1}")

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
          with {:ok, server_pid} <- Cache.server_process(cache_pid, "List number #{i}") do
            GenServer.stop(server_pid, :normal)
          end
        end
      )

      GenServer.stop(cache_pid, :normal)
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
