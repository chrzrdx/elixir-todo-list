defmodule Server do
  def start(module) do
    spawn(fn -> loop(module, module.init()) end)
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:reply, reply} -> reply
      unhandled_reply -> {:error, :bad_reply, unhandled_reply}
    end
  end

  defp loop(module, state) do
    receive do
      {:call, caller_pid, message} ->
        {reply, new_state} = module.handle_call(state, message)
        send(caller_pid, {:reply, reply})
        loop(module, new_state)
    end
  end
end

defmodule KVStore do
  def init(), do: Map.new()
  def handle_call(store, {:get, key}), do: {Map.get(store, key), store}
  def handle_call(store, {:put, key, value}), do: {:ok, Map.put(store, key, value)}
end

defmodule KVStoreTest do
  def test do
    kv = Server.start(KVStore)
    Server.call(kv, {:put, :name, "Abhinandan"}) |> IO.inspect()
    Server.call(kv, {:put, :email, "abhi@gmail.com"}) |> IO.inspect()
    Server.call(kv, {:get, :name}) |> IO.inspect()
    Server.call(kv, {:get, :email}) |> IO.inspect()
    :ok
  end
end
