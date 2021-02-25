defmodule UnusMotus.Database do
  use GenServer

  # Client

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def save_score(name, score, moves, level) do
    GenServer.call(__MODULE__, {:save, name, score, moves, level})
  end

  def fetch_scores do
    GenServer.call(__MODULE__, {:lookup, 20})
  end

  # Server

  @impl true
  def init(:ok) do
    {:ok, conn} = Mongo.start_link(url: Application.fetch_env!(:unus_motus, :db_uri))
    {:ok, %{conn: conn}}
  end

  @impl true
  def handle_call({:save, name, score, moves, level}, _from, state) do
    {:ok, _} =
      Mongo.insert_one(state.conn, "leaderboard", %{
        name: name,
        score: score,
        moves: moves,
        level: level
      })

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:lookup, num_results}, _from, state) do
    results =
      state.conn
      |> Mongo.find("leaderboard", %{}, sort: %{score: -1})
      |> Enum.take(num_results)

    {:reply, results, state}
  end
end
