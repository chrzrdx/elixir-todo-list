defmodule Calculator.Pooler do
  defstruct pids: MapSet.new()

  alias Calculator.Pooler
  alias Calculator.Server

  def start() do
    spawn(fn ->
      pids = for _ <- 1..10, into: MapSet.new(), do: Server.start()

      loop(%Pooler{pids: pids})
    end)
  end

  defp loop(%Pooler{pids: pids} = pooler) do
    receive do
      message ->
        IO.inspect(message)
        random_pid = Enum.random(pids)
        send(random_pid, message)
    end

    loop(pooler)
  end
end
