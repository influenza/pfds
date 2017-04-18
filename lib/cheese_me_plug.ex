
defmodule CheeseMe.Plug do
  use Plug.Router
  require CheeseMe
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  @name_gen Application.fetch_env!(:cheese_me, :name_generator)

  @aliases @name_gen.get_enumerable("./data/cheeses.txt", "./data/surnames.txt")

  def init(options), do: options

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http CheeseMe.Plug, []
  end

  get "/" do
    IO.inspect @name_gen
    name = @aliases |> Enum.shuffle |> Enum.take(1) |> Enum.join
    message = cond do
      name == "colby chavez" -> ":100: :thumbsup: !! Colby Chavez !! :thumbsup: :100:"
      true -> name
    end
    resp = ~s({ "response_type": "in_channel", "text": "#{message}", "attachments": [] })

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
