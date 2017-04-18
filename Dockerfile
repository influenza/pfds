FROM elixir:1.4.2-slim

ADD rel/pfds/bin/cheese_me /usr/local/bin/cheese_me

ENTRYPOINT ["/usr/local/bin/cheese_me"]
CMD ["foreground"]
