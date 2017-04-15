defmodule PfdsApplication do
  use Application
  require Logger

  def main(args), do: args

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Pfds.Plug, [], port: 8080)
    ]

    Logger.info "Started application"

    Supervisor.start_link(children, strategy: :one_for_one)

    :timer.sleep(:infinity)
  end
end
