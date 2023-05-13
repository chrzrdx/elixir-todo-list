defmodule Calculator.Server do
  def start() do
    spawn(fn -> loop() end)
  end

  defp loop() do
    receive do
      {pid, :add, {x, y}} -> ack(pid, {:ok, x + y})
      {pid, :sub, {x, y}} -> ack(pid, {:ok, x - y})
      {pid, :mul, {x, y}} -> ack(pid, {:ok, x * y})
      {pid, :div, {_, 0}} -> ack(pid, {:error, :division_by_zero})
      {pid, :div, {x, y}} -> ack(pid, {:ok, x / y})
    after
      60000 -> :ok
    end

    loop()
  end

  defp ack(caller_pid, message) do
    Process.sleep(5000)
    spawn(fn -> send(caller_pid, message) end)
  end
end
