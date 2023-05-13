defmodule Todo.Server do
  use GenServer

  @impl GenServer
  def init(_) do
    {:ok, Todo.List.new()}
  end

  @impl GenServer
  def handle_call({:entries, %Date{} = date}, _, todos) do
    {:reply, Todo.List.entries(todos, date), todos}
  end

  @impl GenServer
  def handle_cast({:add_entry, %{date: date, title: title}}, todos) do
    {:noreply, Todo.List.add_entry(todos, %{date: date, title: title})}
  end

  @impl GenServer
  def handle_cast({:update_entry, id, update_fn}, todos) do
    {:noreply, Todo.List.update_entry(todos, id, update_fn)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, id}, todos) do
    {:noreply, Todo.List.delete_entry(todos, id)}
  end

  # public facing functions
  def start(), do: GenServer.start(__MODULE__, nil)

  def add_entry(server_pid, todo), do: GenServer.cast(server_pid, {:add_entry, todo})

  def entries(server_pid, %Date{} = date), do: GenServer.call(server_pid, {:entries, date})

  def update_entry(server_pid, id, update_fn),
    do: GenServer.cast(server_pid, {:update_entry, id, update_fn})

  def delete_entry(server_pid, id), do: GenServer.cast(server_pid, {:delete_entry, id})
end
