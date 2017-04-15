FROM elixir:1.4.2-slim

ADD pfds /usr/local/bin/pfds

ENTRYPOINT ["/usr/local/bin/pfds"]
