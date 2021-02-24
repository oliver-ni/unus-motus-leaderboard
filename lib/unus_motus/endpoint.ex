defimpl Jason.Encoder, for: BSON.ObjectId do
  def encode(value, _opts) do
    "\"" <> BSON.ObjectId.encode!(value) <> "\""
  end
end

defmodule UnusMotus.Endpoint do
  alias UnusMotus.Database
  use Plug.Router

  plug Plug.Logger
  plug Corsica, origins: "*"

  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Pong!")
  end

  get "/leaderboard" do
    send_as_json(conn, 200, Database.fetch_scores())
  end

  post "/leaderboard" do
    {status, data} =
      case conn.body_params do
        %{"name" => name, "score" => score} when is_binary(name) and is_integer(score) ->
          :ok = Database.save_score(name, score)
          {200, %{status: "success"}}

        _ ->
          {400, %{status: "error", error: "Invalid name and score params."}}
      end

    send_as_json(conn, status, data)
  end

  match _ do
    conn
    |> send_resp(404, "Page Not Found")
    |> halt()
  end

  defp send_as_json(conn, status, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(data))
  end
end
