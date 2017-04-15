require Pfds

defmodule Pfds.Plug do
  @first_names_list MultiMap.to_list(Pfds.load_and_map("./data/cheeses.txt"))

  @surnames Pfds.load_and_map("./data/surnames.txt")

  def init(options), do: options

  def call(conn, _opts) do
    name_list = Pfds.pull_alias(@first_names_list, @surnames, 1)
    name = hd(name_list)
    resp = ~s({ "response_type": "in_channel", "text": "#{name}", "attachments": [] })

    conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, resp)
  end
end


