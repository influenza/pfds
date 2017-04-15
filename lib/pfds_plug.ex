require Pfds

defmodule Pfds.Plug do
  @first_names_list MultiMap.to_list(Pfds.load_and_map("./data/cheeses.txt"))

  @surnames Pfds.load_and_map("./data/surnames.txt")

  def init(options), do: options

  def call(conn, _opts) do
    name_list = Pfds.pull_alias(@first_names_list, @surnames, 1)
    name = hd(name_list)

    conn
      |> Plug.Conn.put_resp_content_type("text/plain")
      |> Plug.Conn.send_resp(200, "#{name}")
  end
end
