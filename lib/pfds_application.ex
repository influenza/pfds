defmodule PfdsApplication do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Pfds.Plug, [], port: 8080)
    ]

    Logger.info "Started application"

    Supervisor.start_link(children, [strategy: :one_for_one, name: HexVersion.Supervisor])
  end
end
