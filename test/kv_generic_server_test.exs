defmodule KVGenericServerTest do
  use ExUnit.Case

  test "generic server works" do
    kv = GenericServer.start(KV.GenericServer.Store)

    assert is_pid(kv)

    assert GenericServer.call(kv, {:put, :name, "Abhinandan"}) == :ok
    assert GenericServer.call(kv, {:put, :email, "abhi@gmail.com"}) == :ok
    assert GenericServer.cast(kv, {:put, :email, "nandan@gmail.com"}) == :ok
    assert GenericServer.call(kv, {:get, :name}) == "Abhinandan"
    assert GenericServer.call(kv, {:get, :email}) == "nandan@gmail.com"
  end
end
