defmodule KV do
  use GenServer

  @impl GenServer
  def init(_), do: {:ok, Map.new()}

  @impl GenServer
  def handle_call({:get, key}, _, store), do: {:reply, Map.get(store, key), store}

  @impl GenServer
  def handle_cast({:put, key, value}, store), do: {:noreply, Map.put(store, key, value)}

  # public interface to module
  def start, do: GenServer.start(__MODULE__, nil, name: __MODULE__)
  def get(key), do: GenServer.call(__MODULE__, {:get, key})
  def put(key, value), do: GenServer.cast(__MODULE__, {:put, key, value})
end

defmodule KVTest do
  def test do
    with {:ok, _} <- KV.start() do
      KV.put(:name, "Abhinandan") |> IO.inspect()
      KV.put(:email, "nandan@gmail.com") |> IO.inspect()
      KV.get(:name) |> IO.inspect()
      KV.get(:email) |> IO.inspect()
    end
  end
end
