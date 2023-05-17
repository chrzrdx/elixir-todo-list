defmodule Todo.Database do
  defmodule Config do
    defstruct name: Todo.Database, persist_db: "./db/data"
  end

  use GenServer

  @impl GenServer
  def init(%Config{persist_db: persist_db} = config) do
    File.mkdir_p!(persist_db)
    {:ok, {config}}
  end

  @impl GenServer
  def handle_call({:get, key}, caller, {%Config{} = config} = state) do
    spawn(fn ->
      reply =
        case File.read(file_name(config, key)) do
          {:ok, contents} -> :erlang.binary_to_term(contents)
          _ -> nil
        end

      GenServer.reply(caller, reply)
    end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:store, key, value}, {%Config{} = config} = state) do
    spawn(fn -> file_name(config, key) |> File.write!(:erlang.term_to_binary(value)) end)

    {:noreply, state}
  end

  def start(args \\ %Config{}) do
    GenServer.start(__MODULE__, args, name: args.name)
  end

  def store(config \\ %Config{}, key, value) do
    GenServer.cast(config.name, {:store, key, value})
  end

  def get(config \\ %Config{}, key) do
    GenServer.call(config.name, {:get, key})
  end

  def file_name(config \\ %Config{}, key) do
    Path.join([config.persist_db, key])
  end
end
