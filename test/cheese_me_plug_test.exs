defmodule CheeseMe.Plug.Test do
  use ExUnit.Case
  use Plug.Test

  @opts CheeseMe.Plug.init([])

  test "/ endpoint returns a value" do
    # Create a test connection
    conn = conn(:get, "/")

    # Invoke the plug
    conn = CheeseMe.Plug.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == ~s({ "response_type": "in_channel", "text": "flowy fan", "attachments": [] })

  end
end
