FROM elixir:1.4.2-slim

ADD rel/pfds/bin/pfds /usr/local/bin/pfds

ENTRYPOINT ["/usr/local/bin/pfds"]
CMD ["foreground"]
