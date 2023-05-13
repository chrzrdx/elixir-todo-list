defmodule KVTest do
  use ExUnit.Case

  test "the key value store works" do
    with {:ok, _} <- KV.Server.start() do
      assert KV.Server.put(:name, "Abhinandan") == :ok
      assert KV.Server.put(:email, "nandan@gmail.com") == :ok
      assert KV.Server.put(:name, "Panigrahi") == :ok
      assert KV.Server.get(:name) == "Panigrahi"
      assert KV.Server.get(:email) == "nandan@gmail.com"
    end
  end
end
