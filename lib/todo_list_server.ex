defmodule TodoList.Server do
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
    alias TodoList.Server

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

defmodule TodoList.RegisteredServer do
  def start() do
    pid = spawn(fn -> loop(TodoList.new()) end)
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

defmodule TodoList.GenServer do
  use GenServer

  @impl GenServer
  def init(_) do
    {:ok, TodoList.new()}
  end

  @impl GenServer
  def handle_call({:entries, %Date{} = date}, _, todos) do
    {:reply, TodoList.entries(todos, date), todos}
  end

  @impl GenServer
  def handle_cast({:add_entry, %{date: date, title: title}}, todos) do
    {:noreply, TodoList.add_entry(todos, %{date: date, title: title})}
  end

  @impl GenServer
  def handle_cast({:update_entry, id, update_fn}, todos) do
    {:noreply, TodoList.update_entry(todos, id, update_fn)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, id}, todos) do
    {:noreply, TodoList.delete_entry(todos, id)}
  end

  # public facing functions
  def start(), do: GenServer.start(__MODULE__, nil, name: __MODULE__)

  def add_entry(todo), do: GenServer.cast(__MODULE__, {:add_entry, todo})

  def entries(%Date{} = date), do: GenServer.call(__MODULE__, {:entries, date})

  def update_entry(id, update_fn), do: GenServer.cast(__MODULE__, {:update_entry, id, update_fn})

  def delete_entry(id), do: GenServer.cast(__MODULE__, {:delete_entry, id})

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
