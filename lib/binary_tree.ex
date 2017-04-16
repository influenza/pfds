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

  @doc """
  True if the set is empty, false otherwise.
  """
  def is_empty?(set)
  def is_empty?(nil), do: true
  def is_empty?(_), do: false

  @doc """
  True if 'value' is found within set, false otherwise.
  """
  def member?(value, set)
  def member?(_, nil), do: false
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

  defp _insert(value, nil) do
    %BinaryTree{ item: value }
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
  def merge(nil, nil), do: nil
  def merge(%BinaryTree{}=x, nil), do: x
  def merge(nil, %BinaryTree{}=y), do: y
  def merge(x, y) do
    if count(x) >= count(y) do
      # Add all elements of y into x
      BinaryTree.reduce(y, x, &insert/2)
    else
      # Add all elements of x into y
      BinaryTree.reduce(x, y, &insert/2)
    end
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

  defp _delete(_, nil), do: raise MissingValueException
  defp _delete(value, %BinaryTree{item: item}=set) when value < item do
    %BinaryTree{ left: _delete(value, set.left), item: set.item, right: set.right }
  end

  defp _delete(value, %BinaryTree{item: item}=set) when value > item do
    %BinaryTree{ left: set.left, item: set.item, right: _delete(value, set.right) }
  end

  defp _delete(_, tree), do: merge(tree.left, tree.right)

  @doc """
  Count the number of elements in this tree
  """
  def count(tree)
  def count(tree), do: BinaryTree.reduce tree, 0, fn (_, acc) -> 1 + acc end


  @doc """
  Performs an in-order traversal
  """
  def reduce(tree, acc, fun)
  def reduce(nil, acc, _), do: acc
  def reduce(%BinaryTree{left: left, item: item, right: right}, acc, fun) do
    # process the left
    left_accumulated = reduce(left, acc, fun)
    # then myself
    self_accumulated = fun.(item, left_accumulated)
    # then the right
    reduce(right, self_accumulated, fun)
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
