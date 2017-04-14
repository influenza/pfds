defmodule BinaryTree do
  @moduledoc """
  Binary search tree implementation.
  Each node's value is greater than the value of each node in its
  left subtree and less than the value of each node in its right
  subtree.

  This implementation behaves as a Set
  """

  defmodule DuplicateValueException do
    @moduledoc """
    This exception is thrown when an existing value is being inserted into a set. By throwing
    and handling this exception, the unnecessary copying of the search path may be avoided.
    """
    defexception message: "The value to be inserted was already present"
  end

  defmodule MissingValueException do
    @moduledoc """
    This exception is thrown when a value that is not present in the set is being deleted.
    By  handling this exception, the unnecessary copying of the search path may be avoided.
    """
    defexception message: "The value to be deleted is not present"
  end

  defstruct [:left, :item, :right]

  @terminal %{left: nil, item: nil, right: nil}

  @doc """
  True if the set is empty, false otherwise.
  """
  def empty?(set)
  def empty?(@terminal), do: true
  def empty?(_), do: false

  @doc """
  True if 'value' is found within set, false otherwise.
  """
  def member?(value, set)
  def member?(_, @terminal), do: false
  def member?(value, %BinaryTree{item: item}=set) when value < item do
    member?(value, set.left)
  end
  def member?(value, %BinaryTree{item: item}=set) when value > item do
    member?(value, set.right)
  end
  def member?(_, _), do: true

  @doc """
  Insert the provided value into the provided set.
  If the value already exists within the set, no copying is performed and the original set
  is returned.
  """
  def insert(value, set) do
    try do
      _insert(value, set)
    rescue
      DuplicateValueException -> set
    end
  end

  defp _insert(value, @terminal) do
    %BinaryTree{
      left: @terminal,
      item: value,
      right: @terminal
    }
  end
  defp _insert(value, %BinaryTree{item: item}=set) when value < item do
    %BinaryTree{
      left: _insert(value, set.left),
      item: set.item,
      right: set.right
    }
  end
  defp _insert(value, %BinaryTree{item: item}=set) when value > item do
    %BinaryTree{
      left: set.left,
      item: set.item,
      right: _insert(value, set.right)
    }
  end
  defp _insert(_, _), do: raise DuplicateValueException

  @doc """
  Merges two sets into a unified view.
  """
  def merge(first_set, second_set)
  def merge(@terminal, @terminal), do: @terminal
  def merge(%BinaryTree{}=x, @terminal), do: x
  def merge(@terminal, %BinaryTree{}=y), do: y
  def merge(%BinaryTree{item: xvalue}=x, %BinaryTree{item: yvalue}=y) when xvalue < yvalue do
    %BinaryTree{
      left: merge(x, y.left),
      item: yvalue,
      right: y.right
    }
  end
  def merge(%BinaryTree{item: xvalue}=x, %BinaryTree{item: yvalue}=y) when xvalue > yvalue do
    %BinaryTree{
      left: y.left,
      item: yvalue,
      right: merge(x, y.right)
    }
  end
  def merge(%BinaryTree{item: value}=x, %BinaryTree{item: value}=y) do
    %BinaryTree{
      left: merge(x.left, y.left),
      item: value,
      right: merge(x.right, y.right)
    }
  end

  @doc """
  Delete the specified value from the provided set.
  If the value is not found, no copying is performed and the original set is returned.
  """
  def delete(value, set) do
    try do
      _delete(value, set)
    rescue
      MissingValueException -> set
    end
  end

  defp _delete(_, @terminal), do: raise MissingValueException
  defp _delete(_, %BinaryTree{left: @terminal, right: @terminal}), do: @terminal
  defp _delete(value, %BinaryTree{left: @terminal, item: value, right: right}), do: right
  defp _delete(value, %BinaryTree{left: left, item: value, right: @terminal}), do: left
  defp _delete(value, %BinaryTree{item: item}=set) when value < item do
    %BinaryTree{
      left: _delete(value, set.left),
      item: set.item,
      right: set.right
    }
  end

  defp _delete(value, %BinaryTree{item: item}=set) when value > item do
    %BinaryTree{
      left: set.left,
      item: set.item,
      right: _delete(value, set.right)
    }
  end

  defp _delete(_, %BinaryTree{left: %BinaryTree{}=left, right: %BinaryTree{}=right}) do
    %BinaryTree{
      left: merge(left, right.left),
      item: right.item,
      right: right.right
    }
  end

  @doc """
  Performs an in-order traversal
  """
  def reduce(tree, acc, fun)
  def reduce(@terminal, acc, _), do: acc
  def reduce(%BinaryTree{left: left, item: item, right: right}, acc, fun) do
    # process the left
    left_accumulated = reduce(left, acc, fun)
    # then myself
    self_accumulated = fun.(item, left_accumulated)
    # then the right
    reduce(right, self_accumulated, fun)
  end

  def go() do
    s = 1..10
        |> Enum.shuffle
        |> Enum.reduce(@terminal, &BinaryTree.insert/2)
    IO.puts "Built a set from 1..10 shuffled:"
    IO.inspect s

    IO.puts "Inserting another shuffled 1..10, expecting no change:"
    s2 = 1..10
      |> Enum.shuffle
      |> Enum.reduce(s, &BinaryTree.insert/2)
    IO.inspect s2

    IO.puts "Deleting 3"
    IO.inspect delete(3, s)

    IO.puts "Reducing the tree"
    Enum.reduce(s, 0, fn (x, _) -> IO.puts x end)

    IO.puts "Count: #{Enum.count(s)}"
  end
end

defimpl Enumerable, for: BinaryTree do
  @doc """
  Performs an in-order traversal
  """
  def reduce(tree, acc, fun), do: BinaryTree.reduce(tree, acc, fun)
  def count(tree) do
    { :ok, BinaryTree.reduce(tree, 0, fn (_, acc) -> 1 + acc end) }
  end
  def member?(tree, x) do
    { :ok, BinaryTree.member?(x, tree) }
  end
end
