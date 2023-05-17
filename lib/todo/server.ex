defmodule Todo.Server do
  alias Todo.Database.Config, as: DatabaseConfig
  alias Todo.Database

  defmodule Config do
    defstruct key: nil, db: %DatabaseConfig{}
  end

  use GenServer

  @impl GenServer
  def init(%Config{key: nil} = config) do
    todos = Todo.List.new()
    {:ok, {config, todos}}
  end

  @impl GenServer
  def init(%Config{} = config) do
    todos = Database.get(config.db, config.key) || Todo.List.new()
    {:ok, {config, todos}}
  end

  @impl GenServer
  def handle_call({:entries, %Date{} = date}, _, {_, todos} = state) do
    {:reply, Todo.List.entries(todos, date), state}
  end

  @impl GenServer
  def handle_cast({:add_entry, %{date: date, title: title}}, {config, todos}) do
    new_todos = Todo.List.add_entry(todos, %{date: date, title: title})
    Todo.Database.store(config.db, config.key, new_todos)
    {:noreply, {config, new_todos}}
  end

  @impl GenServer
  def handle_cast({:update_entry, id, update_fn}, {config, todos}) do
    new_todos = Todo.List.update_entry(todos, id, update_fn)
    Todo.Database.store(config.db, config.key, new_todos)
    {:noreply, {config, new_todos}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, id}, {config, todos}) do
    new_todos = Todo.List.delete_entry(todos, id)
    Todo.Database.store(config.db, config.key, new_todos)
    {:noreply, {config, new_todos}}
  end

  # public facing functions
  def start(config \\ %Config{}), do: GenServer.start(__MODULE__, config)

  def add_entry(server_pid, todo), do: GenServer.cast(server_pid, {:add_entry, todo})

  def entries(server_pid, %Date{} = date), do: GenServer.call(server_pid, {:entries, date})

  def update_entry(server_pid, id, update_fn),
    do: GenServer.cast(server_pid, {:update_entry, id, update_fn})

  def delete_entry(server_pid, id), do: GenServer.cast(server_pid, {:delete_entry, id})
end
