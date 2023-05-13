defmodule KV.GenericServer.Store.Test do
  def test do
    kv = GenericServer.start(KV.GenericServer)
    GenericServer.call(kv, {:put, :name, "Abhinandan"}) |> IO.inspect()
    GenericServer.call(kv, {:put, :email, "abhi@gmail.com"}) |> IO.inspect()
    GenericServer.cast(kv, {:put, :email, "nandan@gmail.com"}) |> IO.inspect()
    GenericServer.call(kv, {:get, :name}) |> IO.inspect()
    GenericServer.call(kv, {:get, :email}) |> IO.inspect()
    :ok
  end
end
