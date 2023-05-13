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
