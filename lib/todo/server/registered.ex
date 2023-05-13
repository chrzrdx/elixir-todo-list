defmodule Todo.Server.Registered do
  def start() do
    pid = spawn(fn -> loop(Todo.List.new()) end)
    Process.register(pid, :todo_server)
  end

  def add_entry(todo) do
    send(:todo_server, {:add_entry, todo})
  end

  def entries(%Date{} = date) do
    send(:todo_server, {:entries, date, self()})

    receive do
      {:reply, entries_for_date} ->
        {:ok, entries_for_date}
    after
      10_000 -> {:error, :timeout}
    end
  end

  def update_entry(id, update_fn) do
    send(:todo_server, {:update_entry, id, update_fn})
  end

  def delete_entry(id) do
    send(:todo_server, {:delete_entry, id})
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
    Todo.List.add_entry(todos, %{date: date, title: title})
  end

  defp handle_message(todos, {:entries, %Date{} = date, caller_pid}) do
    send(caller_pid, {:reply, Todo.List.entries(todos, date)})
    todos
  end

  defp handle_message(todos, {:update_entry, id, update_fn}) do
    Todo.List.update_entry(todos, id, update_fn)
  end

  defp handle_message(todos, {:delete_entry, id}) do
    Todo.List.delete_entry(todos, id)
  end

  def test() do
    __MODULE__.start()

    __MODULE__.add_entry(%{date: ~D[2023-05-03], title: "get groceries"})
    __MODULE__.add_entry(%{date: ~D[2023-05-02], title: "write journal"})
    __MODULE__.add_entry(%{date: ~D[2023-05-05], title: "buy coconut"})
    __MODULE__.add_entry(%{date: ~D[2023-05-03], title: "sell feet pics"})
    __MODULE__.add_entry(%{date: ~D[2023-05-03], title: "redeem coupon"})
    __MODULE__.add_entry(%{date: ~D[2023-05-02], title: "sing a song"})

    __MODULE__.entries(~D[2023-05-03])
  end
end
