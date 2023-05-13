defmodule Todo.Server.Basic do
  def start() do
    spawn(fn -> loop(TodoList.new()) end)
  end

  def add_entry(pid, todo) do
    send(pid, {:add_entry, todo})
  end

  def entries(pid, %Date{} = date) do
    send(pid, {:entries, date, self()})

    receive do
      {:reply, entries_for_date} ->
        {:ok, entries_for_date}
    after
      10_000 -> {:error, :timeout}
    end
  end

  def update_entry(pid, id, update_fn) do
    send(pid, {:update_entry, id, update_fn})
  end

  def delete_entry(pid, id) do
    send(pid, {:delete_entry, id})
  end

  defp loop(state) do
    new_state =
      receive do
        message ->
          handle_message(state, message)
      end

    loop(new_state)
  end

  defp handle_message(todos, {:add_entry, %{date: date, title: title}}) do
    TodoList.add_entry(todos, %{date: date, title: title})
  end

  defp handle_message(todos, {:entries, %Date{} = date, caller_pid}) do
    send(caller_pid, {:reply, TodoList.entries(todos, date)})
    todos
  end

  defp handle_message(todos, {:update_entry, id, update_fn}) do
    TodoList.update_entry(todos, id, update_fn)
  end

  defp handle_message(todos, {:delete_entry, id}) do
    TodoList.delete_entry(todos, id)
  end

  def test() do
    alias Todo.Server.Basic, as: Server

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
