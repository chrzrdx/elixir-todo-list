defmodule Todo.Cache do
  use GenServer

  @impl GenServer
  def init(_), do: {:ok, Map.new()}

  @impl GenServer
  def handle_call({:get_or_create, key}, _, cache) do
    server_pid = Map.get(cache, key) || Todo.Server.start()
    {:reply, server_pid, Map.put(cache, key, server_pid)}
  end

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(key) do
    GenServer.call(__MODULE__, {:get_or_create, key})
  end
end

defmodule Todo.Cache.Test do
  def test(n \\ 10) do
    with {:ok, _} <- Todo.Cache.start() do
      Enum.each(1..n, &Todo.Cache.server_process("List number #{&1}"))
    end

    {:ok, alice} = Todo.Cache.server_process("List number 1")
    {:ok, bob} = Todo.Cache.server_process("List number #{n + 1}")

    Todo.Server.add_entry(alice, %{date: ~D[2023-05-03], title: "get groceries"})
    Todo.Server.add_entry(alice, %{date: ~D[2023-05-02], title: "write journal"})
    Todo.Server.add_entry(alice, %{date: ~D[2023-05-05], title: "buy coconut"})
    Todo.Server.add_entry(alice, %{date: ~D[2023-05-03], title: "sell feet pics"})

    Todo.Server.add_entry(bob, %{date: ~D[2023-05-03], title: "redeem coupon"})
    Todo.Server.add_entry(bob, %{date: ~D[2023-05-02], title: "sing a song"})

    Todo.Server.entries(alice, ~D[2023-05-03]) |> IO.inspect()
    Todo.Server.entries(bob, ~D[2023-05-03]) |> IO.inspect()
    Todo.Server.entries(bob, ~D[2023-05-10]) |> IO.inspect()

    Enum.each(
      1..(n + 1),
      fn i ->
        with {:ok, pid} <- Todo.Cache.server_process("List number #{i}") do
          GenServer.stop(pid, :normal)
        end
      end
    )

    GenServer.stop(Todo.Cache, :normal)
  end
end
