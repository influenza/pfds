defmodule BinaryTree do
  @moduledoc """
  Binary search tree implementation.
  Each node's value is greater than the value of each node in its
  left subtree and less than the value of each node in its right
  subtree.

  This implementation behaves as a Set
  """

  defmodule DuplicateValueException do
    defexception message: "value exists"
  end

  defmodule MissingValueException do
    defexception message: "value exists"
  end

  defstruct [:left, :item, :right]

  @terminal %{left: nil, item: nil, right: nil}

  def is_empty?(@terminal), do: true
  def is_empty?(_), do: false

  def is_member?(_, @terminal), do: false
  def is_member?(value, %BinaryTree{item: item}=set) when value < item do
    is_member?(value, set.left)
  end
  def is_member?(value, %BinaryTree{item: item}=set) when value > item do
    is_member?(value, set.right)
  end
  def is_member?(_, _), do: true

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
  end
end
