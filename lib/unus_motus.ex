defmodule UnusMotus do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UnusMotus.Database,
      {Plug.Cowboy, scheme: :http, plug: UnusMotus.Endpoint, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: UnusMotus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
