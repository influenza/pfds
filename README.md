![travis build status](https://travis-ci.org/influenza/pfds.svg?branch=master)


# Purely Functional Data Structures

This repository is where I collect scratch modules used while working through
Chris Okasaki's [Purely Functional Data Structures](https://www.amazon.com/Purely-Functional-Structures-Chris-Okasaki/dp/0521663504)


## For the Wolfies

Generate some names with:

        mix escript.build
        ./pfds --firstnames /path/to/firstnames.txt --surnames /path/to/surnames.txt --count 100

Or just startup iex and hit you browser

        $ iex -S mix
        iex(1)> import PfdsPlug
        iex(2)> Plug.Adapters.Cowboy.http PfdsPlug, []

Or make an annoying slack bot do your dirty work:

        $ mix -S iex
        iex(1)> ElixirBot.go "YOUR API TOKEN HERE"

Or use it as a docker container:

        $ MIX_ENV=prod mix do deps.get, compile, release
        $ docker build -t cheezy .
        $ docker run -d --rm -p 8080:8080 cheezy
        $ curl http://localhost:8080
