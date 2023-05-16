defmodule Todo.Cache do
  use GenServer

  @impl GenServer
  def init(_) do
    Todo.Database.start()
    {:ok, Map.new()}
  end

  @impl GenServer
  def handle_call({:get_or_create, key}, _, cache) do
    server_pid = Map.get(cache, key) || Todo.Server.start()
    {:reply, server_pid, Map.put(cache, key, server_pid)}
  end

  def start(cache_name \\ __MODULE__) do
    GenServer.start(__MODULE__, nil, name: cache_name)
  end

  def server_process(cache_name \\ __MODULE__, key) do
    GenServer.call(cache_name, {:get_or_create, key})
  end
end
