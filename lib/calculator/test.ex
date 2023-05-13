defmodule Calculator.Test do
  alias Calculator.Client
  alias Calculator.Pooler

  def test() do
    test(Pooler.start())

    # you should see most tasks outputs after 5 seconds
    # and then depending on how congested a particular
    # server is, some client queries to that server may
    # time out before the server can respond to them
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
