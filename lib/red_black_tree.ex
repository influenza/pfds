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

  This implementation has two optimizations in place:
    1. Membership tests perform a single comparison and cache a candidate.
      This allows for d+1 rather than 2d comparisons.
    2. On insertion, only nodes on the search path are color-checked for
      balancing.
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
  def member?(value, tree)
  def member?(_, nil), do: false
  def member?(value, tree), do: find_with_candidate(value, tree, nil)

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
      { _, %RedBlackTree{}=new_tree }  = ins(value, tree)
      # Return a black-colored node with the same contents
      %RedBlackTree{new_tree | color: @black}
    rescue
      DuplicateValueException -> tree
    end
  end

  defp ins(x, %RedBlackTree{color: c, left: a, item: y, right: b}) when x < y do
    new_tree = case ins(x, a) do
      { :neither, new_left } -> %RedBlackTree{color: c, left: new_left, item: y, right: b}
      { :left, new_left } -> llbalance(c, new_left, y, b)
      { :right, new_left } -> lrbalance(c, new_left, y, b)
    end
    {:left, new_tree}
  end
  defp ins(x, %RedBlackTree{color: c, left: a, item: y, right: b}) when x > y do
    new_tree = case ins(x, b) do
      { :neither, new_right } -> %RedBlackTree{color: c, left: a, item: y, right: new_right}
      { :left, new_right } -> rlbalance(c, a, y, new_right)
      { :right, new_right } -> rrbalance(c, a, y, new_right)
    end
    {:right, new_tree}
  end
  defp ins(x, nil), do: {:neither, %RedBlackTree{color: @red, item: x}}
  defp ins(_, _), do: raise DuplicateValueException

  # Any black node with two red children is replaced with a red node with two black children
  defp llbalance(@black, %{color: @red, left: %{color: @red, left: a, item: x, right: b}, item: y, right: c}, z, d) do
    # Case 1
    %RedBlackTree{
      left: %RedBlackTree{color: @black, left: a, item: x, right: b},
      color: @red, item: y,
      right: %RedBlackTree{color: @black, left: c, item: z, right: d}
    }
  end
  defp llbalance(color, left, item, right), do: %RedBlackTree{color: color, left: left, item: item, right: right}

  defp lrbalance(@black, %{color: @red, left: a, item: x, right: %{color: @red, left: b, item: y, right: c}}, z, d) do
    # Case 2
    %RedBlackTree{
      left: %RedBlackTree{color: @black, left: a, item: x, right: b},
      color: @red, item: y,
      right: %RedBlackTree{color: @black, left: c, item: z, right: d}
    }
  end
  defp lrbalance(color, left, item, right), do: %RedBlackTree{color: color, left: left, item: item, right: right}

  defp rlbalance(@black, a, x, %{color: @red, left: %{color: @red, left: b, item: y, right: c}, item: z, right: d}) do
    # Case 3
    %RedBlackTree{
      left: %RedBlackTree{color: @black, left: a, item: x, right: b},
      color: @red, item: y,
      right: %RedBlackTree{color: @black, left: c, item: z, right: d}
    }
  end
  defp rlbalance(color, left, item, right), do: %RedBlackTree{color: color, left: left, item: item, right: right}

  defp rrbalance(@black, a, x, %{color: @red, left: b, item: y, right: %{color: @red, left: c, item: z, right: d}}) do
    # Case 4
    %RedBlackTree{
      left: %RedBlackTree{color: @black, left: a, item: x, right: b},
      color: @red, item: y,
      right: %RedBlackTree{color: @black, left: c, item: z, right: d}
    }
  end
  defp rrbalance(color, left, item, right), do: %RedBlackTree{color: color, left: left, item: item, right: right}

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

  def _do_enumerable_reduce(nil, acc, _, next), do: next.(acc)
  def _do_enumerable_reduce(
    %RedBlackTree{left: left, item: item, right: right},
    acc, fun, next
  ) do
    # Pass along a simple wrapper function, calling it with the result
    # of the right tree traversal.
    wrapper_fn = fn
        {:halt, acc}    -> {:halted, acc}
        {:cont, acc}    -> {:cont, acc}
        {:suspended, acc, cont} -> {:suspended, acc, cont}
    end

    # recurse left
    left_side = _do_enumerable_reduce(left, acc, fun, wrapper_fn)
    if elem(left_side, 0) == :suspended do
      left_side
    else
      # Process this node
      {_ , left_acc} = left_side
      case fun.(item, left_acc) do
        { :halt, acc } -> { :halted, acc }
        # recurse right in a continuation
        { :suspend, acc } -> { :suspended, acc, fn
          (new_acc) -> _do_enumerable_reduce(right, new_acc, fun, wrapper_fn)
        end}
        # recurse right, then apply `next`
        x -> next.(_do_enumerable_reduce(right, x, fun, wrapper_fn))
      end
    end
  end

  defimpl Enumerable do
    def reduce(rbtree, acc, fun) do
      # This function will be wrapped with each recursion. The intent is that it serves
      # as a sentinel on the stack to track when enumeration is complete
      end_of_traversal_fn =  fn
        {:suspend, acc} -> {:suspended, acc, &{:done, elem(&1, 1)}}
        {:halt, acc}    -> {:halted, acc}
        {:cont, acc}    -> {:done, acc}
      end
      RedBlackTree._do_enumerable_reduce(rbtree, acc, fun, end_of_traversal_fn)
    end

    def member?(rbtree, val), do: {:ok, RedBlackTree.member?(val, rbtree)}
    def count(rbtree), do: {:ok, RedBlackTree.count(rbtree)}
  end
end
