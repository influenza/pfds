defmodule RedBlackTree do
  @moduledoc """
  Red-black search tree implementation.
  Each node's value is greater than the value of each node in its
  left subtree and less than the value of each node in its right
  subtree.

  Empty nodes are black.

  Two invariants are enforced:
  1. No red node has a red child
  2. Every path from the root to an empty node has the same number
    of black nodes
  """

  defmodule DuplicateValueException do
    @moduledoc """
    This exception is thrown when an existing value is being inserted into the tree. By throwing
    and handling this exception, the unnecessary copying of the search path may be avoided.
    """
    defexception message: "The value to be inserted was already present"
  end

  defmodule MissingValueException do
    @moduledoc """
    This exception is thrown when a value that is not present in the tree is being deleted.
    By  handling this exception, the unnecessary copying of the search path may be avoided.
    """
    defexception message: "The value to be deleted is not present"
  end

  @red :red
  @black :black

  defstruct [color: @black, left: nil, item: nil, right: nil]

  @doc """
  True if the tree is empty, false otherwise.
  """
  def is_empty?(tree)
  def is_empty?(nil), do: true
  def is_empty?(_), do: false

  @doc """
  True if 'value' is found within tree, false otherwise.
  """
  def member?(value, tree) do
    find_with_candidate(value, tree, nil)
  end

  defp find_with_candidate(value, %RedBlackTree{item: key, left: left}, candidate) when value < key do
    if left != nil do
      find_with_candidate(value, left, candidate)
    else
      value == candidate
    end
  end

  defp find_with_candidate(value, %RedBlackTree{item: key, right: right}, _) do
    if right != nil do
      find_with_candidate(value, right, key)
    else
      key == value
    end
  end

  @doc """
  Insert the provided value into the provided tree.
  If the value already exists within the tree, no copying is performed and the original tree
  is returned.
  """
  def insert(value, tree) do
    try do
      %RedBlackTree{left: a, item: x, right: b}  = ins(value, tree)
      # Return a black-colored node with the same contents
      %RedBlackTree{color: @black, left: a, item: x, right: b }
    rescue
      DuplicateValueException -> tree
    end
  end

  defp ins(x, nil), do: %RedBlackTree{color: @red, item: x}
  defp ins(x, %RedBlackTree{color: c, left: a, item: y, right: b}) do
    cond do
      x < y -> balance(c, ins(x, a), y, b)
      x > y -> balance(c, a, y, ins(x, b))
      true -> raise DuplicateValueException
    end
  end

  # Any black node with two red children is replaced with a red node with two black children
  defp balance(@black, %{color: @red, left: %{color: @red, left: a, item: x, right: b}, item: y, right: c}, z, d) do
    # Case 1
    %RedBlackTree{
      left: %RedBlackTree{color: @black, left: a, item: x, right: b},
      color: @red, item: y,
      right: %RedBlackTree{color: @black, left: c, item: z, right: d}
    }
  end
  defp balance(@black, %{color: @red, left: a, item: x, right: %{color: @red, left: b, item: y, right: c}}, z, d) do
    # Case 2
    %RedBlackTree{
      left: %RedBlackTree{color: @black, left: a, item: x, right: b},
      color: @red, item: y,
      right: %RedBlackTree{color: @black, left: c, item: z, right: d}
    }
  end
  defp balance(@black, a, x, %{color: @red, left: %{color: @red, left: b, item: y, right: c}, item: z, right: d}) do
    # Case 3
    %RedBlackTree{
      left: %RedBlackTree{color: @black, left: a, item: x, right: b},
      color: @red, item: y,
      right: %RedBlackTree{color: @black, left: c, item: z, right: d}
    }
  end
  defp balance(@black, a, x, %{color: @red, left: b, item: y, right: %{color: @red, left: c, item: z, right: d}}) do
    # Case 4
    %RedBlackTree{
      left: %RedBlackTree{color: @black, left: a, item: x, right: b},
      color: @red, item: y,
      right: %RedBlackTree{color: @black, left: c, item: z, right: d}
    }
  end
  defp balance(color, left, item, right), do: %RedBlackTree{color: color, left: left, item: item, right: right}

  @doc """
  Count the number of elements in this tree
  """
  def count(tree)
  def count(tree), do: RedBlackTree.reduce tree, 0, fn (_, acc) -> 1 + acc end

  def depth(nil), do: 0
  def depth(%RedBlackTree{}=tree) do
    left_depth = depth(tree.left)
    right_depth = depth(tree.right)
    1 + (if left_depth > right_depth do left_depth else right_depth end)
  end

  @doc """
  Performs an in-order traversal
  """
  def reduce(tree, acc, fun)
  def reduce(nil, acc, _), do: acc
  def reduce(%RedBlackTree{left: left, item: item, right: right}, acc, fun) do
    # process the left
    left_accumulated = reduce(left, acc, fun)
    # then myself
    self_accumulated = fun.(item, left_accumulated)
    # then the right
    reduce(right, self_accumulated, fun)
  end
end
