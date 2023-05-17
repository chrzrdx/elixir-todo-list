defmodule Todo.Cache do
  alias Todo.Database
  alias Todo.Database.Config, as: DatabaseConfig
  alias Todo.Server
  alias Todo.Server.Config, as: ServerConfig

  defmodule Config do
    defstruct name: Todo.Cache, db: %DatabaseConfig{}
  end

  use GenServer

  @impl GenServer
  def init(%Config{} = config) do
    {:ok, _} = Database.start(config.db)
    cache = Map.new()
    {:ok, {config, cache}}
  end

  @impl GenServer
  def handle_call({:get_or_create, key}, _, {config, cache}) do
    server_config = %ServerConfig{db: config.db, key: key}
    server_pid = Map.get(cache, key) || Server.start(server_config)
    new_cache = Map.put(cache, key, server_pid)
    {:reply, server_pid, {config, new_cache}}
  end

  def start(config \\ %Config{}) do
    GenServer.start(__MODULE__, config, name: config.name)
  end

  def server_process(config \\ %Config{}, key) do
    GenServer.call(config.name, {:get_or_create, key})
  end
end
