
defmodule Pfds.Plug do
  use Plug.Router
  require Pfds
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  @first_names_list MultiMap.to_list(Pfds.load_and_map("./data/cheeses.txt"))

  @surnames Pfds.load_and_map("./data/surnames.txt")

  def init(options), do: options

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http Pfds.Plug, []
  end

  get "/" do
    name_list = Pfds.pull_alias(@first_names_list, @surnames, 1)
    name = hd(name_list)
    resp = ~s({ "response_type": "in_channel", "text": "#{name}", "attachments": [] })

    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, resp)
      |> halt
  end

  match _ do
    conn
    |> send_resp(404, "Nothing here")
    |> halt
  end

end
