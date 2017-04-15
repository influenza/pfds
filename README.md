# Purely Functional Data Structures

This repository is where I collect scratch modules used while working through
Chris Okasaki's [Purely Functional Data Structures](https://www.amazon.com/Purely-Functional-Structures-Chris-Okasaki/dp/0521663504)


## For the Wolfies

Generate some names with:

        mix escript.build
        ./pfds --firstnames /path/to/firstnames.txt --surnames /path/to/surnames.txt --count 100

Or just startup iex and hit you browser

```
  $ mix -S iex
  iex> import PdfsPlug
  iex> Plug.Adapters.Cowboy.http PdfsPlug, []
```

Or make an annoying slack bot do your dirty work:

        $ mix -S iex
        iex(1)> ElixirBot.go "YOUR API TOKEN HERE"

Or use it as a docker container:

```
  $ mix deps.get
  $ MIX_ENV=prod mix escript.build
  $ docker build -t cheezy .
  $ docker run --rm -p 8080:8080 cheezy
  $ docker run -p 8080:8080 cheezy
  $ curl http://localhost:8080
```

