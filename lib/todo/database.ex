defmodule Todo.Database do
  alias __MODULE__
  use GenServer

  defstruct db: __MODULE__, persist_db: "./db/data"

  @impl GenServer
  def init(%Database{persist_db: persist_db} = initial_args) do
    File.mkdir_p!(persist_db)
    {:ok, initial_args}
  end

  @impl GenServer
  def handle_call({:get, key}, _, %Database{} = state) do
    with {:ok, contents} <- File.read(file_name(state, key)) do
      todos = :erlang.binary_to_term(contents)
      {:reply, todos, state}
    else
      _ -> {:reply, nil, state}
    end
  end

  @impl GenServer
  def handle_cast({:store, key, value}, %Database{} = state) do
    File.write!(file_name(state, key), :erlang.term_to_binary(value))

    {:noreply, state}
  end

  def start(args \\ %Database{}) do
    GenServer.start(__MODULE__, args, name: args.db)
  end

  def store(state \\ %Database{}, key, value) do
    GenServer.cast(state.db, {:store, key, value})
  end

  def get(state \\ %Database{}, key) do
    GenServer.call(state.db, {:get, key})
  end

  def file_name(state \\ %Database{}, key) do
    Path.join([state.persist_db, key])
  end
end
