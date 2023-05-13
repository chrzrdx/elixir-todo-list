defmodule KV.GenericServer.Store do
  def init(), do: Map.new()
  def handle_call({:get, key}, store), do: {Map.get(store, key), store}
  def handle_call({:put, key, value}, store), do: {:ok, Map.put(store, key, value)}
  def handle_cast({:put, key, value}, store), do: Map.put(store, key, value)
end
