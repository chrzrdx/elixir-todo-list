defmodule KV.Test do
  def test do
    with {:ok, _} <- KV.Server.start() do
      KV.Server.put(:name, "Abhinandan") |> IO.inspect()
      KV.Server.put(:email, "nandan@gmail.com") |> IO.inspect()
      KV.Server.get(:name) |> IO.inspect()
      KV.Server.get(:email) |> IO.inspect()
    end
  end
end
