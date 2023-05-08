defmodule Calculator.Server do
  def loop() do
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

  def start() do
    spawn(fn -> loop() end)
  end

  defp ack(caller_pid, message) do
    Process.sleep(5000)
    spawn(fn -> send(caller_pid, message) end)
  end
end

defmodule Calculator.Pooler do
  defstruct pids: MapSet.new()

  alias Calculator.Pooler
  alias Calculator.Server

  def start() do
    spawn(fn ->
      pids =
        for id <- 1..100, into: MapSet.new() do
          {id, Server.start()}
        end

      loop(%Pooler{pids: pids})
    end)
  end

  def loop(%Pooler{pids: pids} = pooler) do
    receive do
      message ->
        IO.inspect(message)
        {_, random_pid} = Enum.random(pids)
        send(random_pid, message)
    end

    loop(pooler)
  end
end

defmodule Calculator.Client do
  defstruct server_pid: nil

  alias Calculator.Client

  defp send(nil, _, _), do: raise("No server pid provided")

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

  def add(%Client{} = client, {x, y}), do: send(client, :add, {x, y})
  def sub(%Client{} = client, {x, y}), do: send(client, :sub, {x, y})
  def mul(%Client{} = client, {x, y}), do: send(client, :mul, {x, y})
  def div(%Client{} = client, {x, y}), do: send(client, :div, {x, y})

  def test() do
    %Client{server_pid: self()}
    |> Client.add({2, 7})
    |> Client.div({8, 0})
    |> Client.sub({20, -100})
    |> Client.div({8, 5})
    |> Client.mul({4, 8})
  end

  def test(server_pid) do
    %Client{server_pid: server_pid}
    |> Client.add({2, 7})
    |> Client.div({8, 0})
    |> Client.sub({20, -100})
    |> Client.div({8, 5})
    |> Client.mul({4, 8})
  end
end
