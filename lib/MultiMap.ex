defmodule MultiMap do
  @moduledoc """
  Tree-based multi map.
  Keys may only appear once, values are assumed to be lists. Keys must be orderable.
  """

  defmodule DuplicateValueException do
    @moduledoc """
    This exception is thrown when an existing key is being inserted into the mmap. By throwing
    and handling this exception, the unnecessary copying of the search path may be avoided.
    """
    defexception message: "The value to be inserted was already present"
  end

  defmodule MissingValueException do
    @moduledoc """
    This exception is thrown when a key that is not present in the mmap is being deleted.
    By handling this exception, the unnecessary copying of the search path may be avoided.
    """
    defexception message: "The value to be deleted is not present"
  end

  defstruct [:left, :key, :entries, :right]

  @terminal %{left: nil, key: nil, entries: nil, right: nil}

  @doc """
  True if the mmap is empty, false otherwise.
  """
  def empty?(mmap)
  def empty?(@terminal), do: true
  def empty?(_), do: false

  @doc """
  True if 'key' is found within set, false otherwise.
  """
  def has_key?(key, set)
  def has_key?(_, @terminal), do: false
  def has_key?(key, %MultiMap{key: item}=set) when key < item do
    has_key?(key, set.left)
  end
  def has_key?(key, %MultiMap{key: item}=set) when key > item do
    has_key?(key, set.right)
  end
  def has_key?(_, _), do: true

  @doc """
  Insert value at key in the provided map.
  If the value already exists within the key's entries, no copying is performed.
  """
  def insert(key, value, set) do
    try do
      _insert(key, value, set)
    rescue
      DuplicateValueException -> set
    end
  end

  defp _insert(key, value, @terminal) do
    %MultiMap{
      left: @terminal,
      key: key,
      entries: [value],
      right: @terminal
    }
  end
  defp _insert(key, value, %MultiMap{key: item}=set) when key < item do
    %MultiMap{
      left: _insert(key, value, set.left),
      key: set.key,
      entries: set.entries,
      right: set.right
    }
  end
  defp _insert(key, value, %MultiMap{key: item}=set) when key > item do
    %MultiMap{
      left: set.left,
      key: set.key,
      entries: set.entries,
      right: _insert(key, value, set.right)
    }
  end
  defp _insert(_, value, %MultiMap{entries: entries}=t) do
    if value in entries do
      raise DuplicateValueException
    end

    %MultiMap{
      left: t.left,
      key: t.key,
      entries: [value | t.entries],
      right: t.right
    }
  end

  @doc """
  Merges two multi maps into a unified view. Any keys found in both maps will be
  merged as first.entries ++ second.entries.
  """
  def merge(first, second)
  def merge(@terminal, @terminal), do: @terminal
  def merge(%MultiMap{}=x, @terminal), do: x
  def merge(@terminal, %MultiMap{}=y), do: y
  def merge(%MultiMap{key: xvalue}=x, %MultiMap{key: yvalue}=y) when xvalue < yvalue do
    %MultiMap{
      left: merge(x, y.left),
      key: yvalue,
      entries: y.entries,
      right: y.right
    }
  end
  def merge(%MultiMap{key: xvalue}=x, %MultiMap{key: yvalue}=y) when xvalue > yvalue do
    %MultiMap{
      left: y.left,
      key: yvalue,
      entries: y.entries,
      right: merge(x, y.right)
    }
  end
  def merge(%MultiMap{key: value}=x, %MultiMap{key: value}=y) do
    %MultiMap{
      left: merge(x.left, y.left),
      key: value,
      entries: Enum.concat(x.entries, y.entries),
      right: merge(x.right, y.right)
    }
  end

  @doc """
  Delete the specified key from the provided set.
  If the key is not found, no copying is performed and the original set is returned.
  """
  def delete_key(key, set) do
    try do
      _delete_key(key, set)
    rescue
      MissingValueException -> set
    end
  end

  defp _delete_key(_, @terminal), do: raise MissingValueException
  defp _delete_key(_, %MultiMap{left: @terminal, right: @terminal}), do: @terminal
  defp _delete_key(key, %MultiMap{left: @terminal, key: key, right: right}), do: right
  defp _delete_key(key, %MultiMap{left: left, key: key, right: @terminal}), do: left
  defp _delete_key(key, %MultiMap{key: item}=set) when key < item do
    %MultiMap{
      left: _delete_key(key, set.left),
      key: set.key,
      entries: set.entries,
      right: set.right
    }
  end

  defp _delete_key(key, %MultiMap{key: item}=set) when key > item do
    %MultiMap{
      left: set.left,
      key: set.key,
      entries: set.entries,
      right: _delete_key(key, set.right)
    }
  end

  defp _delete_key(_, %MultiMap{left: %MultiMap{}=left, right: %MultiMap{}=right}) do
    %MultiMap{
      left: merge(left, right.left),
      key: right.key,
      entries: right.entries,
      right: right.right
    }
  end

  @doc """
  Performs an in-order traversal
  """
  def reduce(tree, acc, fun)
  def reduce(@terminal, acc, _), do: acc
  def reduce(%MultiMap{left: left, key: key, right: right}, acc, fun) do
    # process the left
    left_accumulated = reduce(left, acc, fun)
    # then myself
    self_accumulated = fun.(key, left_accumulated)
    # then the right
    reduce(right, self_accumulated, fun)
  end

  @doc """
  Retrieve the entries associated with the specified key, or the empty list if it is not found.
  """
  def get_entries(key, tree)
  def get_entries(_key, @terminal), do: []
  def get_entries(key, %MultiMap{key: nodekey}=m) when key < nodekey, do: get_entries(key, m.left)
  def get_entries(key, %MultiMap{key: nodekey}=m) when key > nodekey, do: get_entries(key, m.right)
  def get_entries(_key, %MultiMap{entries: entries}), do: entries

  def to_list(@terminal), do: []
  def to_list(%MultiMap{left: left, entries: entries, right: right}) do
    left_list = to_list(left)
    right_list = to_list(right)
    Enum.concat(left_list, [entries | right_list])
  end

  @doc """
  This function performs some operations to provide an easy way to exercise this
  module from iex.
  """
  def go() do
    s = ['a', 'b', 'c', 'd', 'e']
        |> Enum.shuffle
        |> Enum.reduce(@terminal, &(MultiMap.insert(&1, 'hey', &2)))
    IO.puts "Built a set from shuffled inputs:"
    IO.inspect s
  end
end
