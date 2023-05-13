defmodule Todo.Server.Test do
  def test() do
    alias Todo.Server

    server = Server.start()

    Server.add_entry(server, %{date: ~D[2023-05-03], title: "get groceries"})
    Server.add_entry(server, %{date: ~D[2023-05-02], title: "write journal"})
    Server.add_entry(server, %{date: ~D[2023-05-05], title: "buy coconut"})
    Server.add_entry(server, %{date: ~D[2023-05-03], title: "sell feet pics"})
    Server.add_entry(server, %{date: ~D[2023-05-03], title: "redeem coupon"})
    Server.add_entry(server, %{date: ~D[2023-05-02], title: "sing a song"})

    Server.entries(server, ~D[2023-05-03])
  end
end
