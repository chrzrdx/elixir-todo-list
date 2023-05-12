defmodule GenericServer do
  def start(module) do
    spawn(fn -> loop(module, module.init()) end)
  end

  def call(pid, message) do
    send(pid, {:call, message, self()})

    receive do
      {:reply, reply} -> reply
      unhandled_reply -> {:error, :bad_reply, unhandled_reply}
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
    :ok
  end

  defp loop(module, state) do
    receive do
      {:call, message, caller_pid} ->
        {reply, new_state} = module.handle_call(message, state)
        send(caller_pid, {:reply, reply})
        loop(module, new_state)

      {:cast, message} ->
        new_state = module.handle_cast(message, state)
        loop(module, new_state)

      _ ->
        loop(module, state)
    end
  end
end

defmodule KVStore do
  def init(), do: Map.new()
  def handle_call({:get, key}, store), do: {Map.get(store, key), store}
  def handle_call({:put, key, value}, store), do: {:ok, Map.put(store, key, value)}
  def handle_cast({:put, key, value}, store), do: Map.put(store, key, value)
end

defmodule KVStoreTest do
  def test do
    kv = GenericServer.start(KVStore)
    GenericServer.call(kv, {:put, :name, "Abhinandan"}) |> IO.inspect()
    GenericServer.call(kv, {:put, :email, "abhi@gmail.com"}) |> IO.inspect()
    GenericServer.cast(kv, {:put, :email, "nandan@gmail.com"}) |> IO.inspect()
    GenericServer.call(kv, {:get, :name}) |> IO.inspect()
    GenericServer.call(kv, {:get, :email}) |> IO.inspect()
    :ok
  end
end
