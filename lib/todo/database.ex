defmodule Todo.Database do
  use GenServer

  @persist_db "./db/data"

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@persist_db)
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    todos =
      file_name(key)
      |> File.read!()
      |> :erlang.binary_to_term()

    %Todo.List{} = todos

    {:reply, todos, state}
  end

  @impl GenServer
  def handle_cast({:store, key, value}, state) do
    file_name(key)
    |> File.write!(:erlang.term_to_binary(value))

    {:noreply, state}
  end

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, value) do
    GenServer.cast(__MODULE__, {:store, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def file_name(key) do
    Path.join([@persist_db, key])
  end
end
