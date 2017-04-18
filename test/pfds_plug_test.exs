defmodule Pfds.Plug.Test do
  use ExUnit.Case
  use Plug.Test

  @opts Pfds.Plug.init([])

  test "/ endpoint returns a value" do
    # Create a test connection
    conn = conn(:get, "/")

    # Invoke the plug
    conn = Pfds.Plug.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
  end
end
