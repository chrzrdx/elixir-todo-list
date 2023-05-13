defmodule Calculator.Client do
  defstruct server_pid: nil

  alias Calculator.Client

  def add(%Client{} = client, {x, y}), do: send(client, :add, {x, y})
  def sub(%Client{} = client, {x, y}), do: send(client, :sub, {x, y})
  def mul(%Client{} = client, {x, y}), do: send(client, :mul, {x, y})
  def div(%Client{} = client, {x, y}), do: send(client, :div, {x, y})

  defp send(%Client{server_pid: nil}, _, _), do: raise("No server pid provided")

  defp send(%Client{server_pid: server_pid} = client, op, args) do
    spawn(fn ->
      self_pid = self()

      Kernel.send(server_pid, {self_pid, op, args})

      receive do
        {:ok, answer} -> IO.puts(answer)
        {:error, reason} -> IO.warn(reason)
      after
        15000 -> IO.warn("Calculator server isn't responding")
      end
    end)

    client
  end
end
