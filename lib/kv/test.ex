defmodule KV.Test do
  def test do
    with {:ok, _} <- KV.start() do
      KV.put(:name, "Abhinandan") |> IO.inspect()
      KV.put(:email, "nandan@gmail.com") |> IO.inspect()
      KV.get(:name) |> IO.inspect()
      KV.get(:email) |> IO.inspect()
    end
  end
end
