defmodule TodoServerTest do
  use ExUnit.Case
  alias Todo.Server

  setup do
    {:ok, server} = Server.start()

    on_exit(fn -> GenServer.stop(server, :normal) end)

    %{server: server}
  end

  test "All public interface functions are implemented", context do
    %{server: server} = context

    Server.add_entry(server, %{date: ~D[2023-05-03], title: "get groceries"})
    Server.add_entry(server, %{date: ~D[2023-05-02], title: "write journal"})
    Server.add_entry(server, %{date: ~D[2023-05-05], title: "buy coconut"})
    Server.add_entry(server, %{date: ~D[2023-05-03], title: "sell cat pics"})
    Server.add_entry(server, %{date: ~D[2023-05-03], title: "redeem coupon"})
    Server.add_entry(server, %{date: ~D[2023-05-02], title: "sing a song"})

    Server.update_entry(server, 6, fn _ -> %{date: ~D[2023-05-02], title: "sing a lullaby"} end)
    Server.update_entry(server, 3, fn _ -> %{title: "buy banana"} end)
    Server.update_entry(server, 3, fn _ -> %{date: ~D[2023-05-02]} end)
    Server.update_entry(server, 3, fn _ -> %{date: ~D[2023-05-06]} end)

    Server.add_entry(server, %{date: ~D[2023-05-03], title: "jog 5km"})

    Server.delete_entry(server, 4)

    assert Server.entries(server, ~D[2023-05-03]) == ["jog 5km", "redeem coupon", "get groceries"]
    assert Server.entries(server, ~D[2023-05-02]) == ["sing a lullaby", "write journal"]
    assert Server.entries(server, ~D[2023-05-05]) == []
    assert Server.entries(server, ~D[2023-05-07]) == []
  end
end
