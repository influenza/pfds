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
