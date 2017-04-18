defmodule ElixirBot do
  @moduledoc """
  Implementation of a slack interface. Currently a copy of the
  sample in the Slack library documentation.
  """
  use Slack

  @name_gen Application.fetch_env!(:cheese_me, :name_generator)

  @aliases @name_gen.get_enumerable("./data/cheeses.txt", "./data/surnames.txt")

  @alias_request_regex ~r/.*(give|gimme|have).*cchavez.*(alias|name).*/

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message", text: msg_text}, slack, state) do
    if seems_like_alias_request(msg_text) do
      send_alias_message(message.channel, state, slack)
    else
      {:ok, state}
    end
  end
  def handle_event(_, _, state), do: {:ok, state}

  defp seems_like_alias_request(text) do
    normalized = String.downcase(text)
    String.match? normalized, @alias_request_regex
  end

  defp send_alias_message(channel, state, slack) do
    selected_alias = @aliases |> Enum.shuffle |> Enum.take(1) |> Enum.join
    msg_text = "How about \"#{selected_alias}\"?"
    send_message(msg_text, channel, slack)
    {:ok, state}
  end


  def handle_info({:message, text, channel}, slack, state) do
    IO.puts "Sending your message, captain!"

    send_message(text, channel, slack)

    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}

  def go(token) do
    Slack.Bot.start_link(ElixirBot, [], token)
  end
end
