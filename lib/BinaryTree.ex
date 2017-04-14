defmodule BinaryTree do
  @moduledoc """
  Binary search tree implementation.
  Each node's value is greater than the value of each node in its
  left subtree and less than the value of each node in its right
  subtree.

  This implementation behaves as a Set
  """

  defstruct [:left, :item, :right]

  @terminal %{left: nil, item: nil, right: nil}

  def is_empty?(@terminal), do: true
  def is_empty?(_), do: false

  def is_member?(_, @terminal), do: false
  def is_member?(value, %BinaryTree{item: value}), do: true

  def is_member?(value, %BinaryTree{item: item}=set) when value < item do
    is_member?(value, set.left)
  end
  def is_member?(value, %BinaryTree{item: item}=set) when value > item do
    is_member?(value, set.right)
  end

  def insert(value, set \\ @terminal)
  def insert(value, @terminal) do
    %BinaryTree{
      left: @terminal,
      item: value,
      right: @terminal
    }
  end
  def insert(value, %BinaryTree{item: value}=set), do: set
  def insert(value, %BinaryTree{item: item}=set) when value < item do
    %BinaryTree{
      left: insert(value, set.left),
      item: set.item,
      right: set.right
    }
  end
  def insert(value, %BinaryTree{item: item}=set) when value > item do
    %BinaryTree{
      left: set.left,
      item: set.item,
      right: insert(value, set.right)
    }
  end

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

  def delete(_, @terminal), do: @terminal
  def delete(_, %BinaryTree{left: @terminal, right: @terminal}), do: @terminal
  def delete(value, %BinaryTree{left: @terminal, item: value, right: right}), do: right
  def delete(value, %BinaryTree{left: left, item: value, right: @terminal}), do: left
  def delete(value, %BinaryTree{left: %BinaryTree{}=left, item: value, right: %BinaryTree{}=right}) do
    %BinaryTree{
      left: merge(left, right.left),
      item: right.item,
      right: right.right
    }
  end

  def delete(value, %BinaryTree{item: item}=set) when value < item do
    %BinaryTree{
      left: delete(value, set.left),
      item: set.item,
      right: set.right
    }
  end

  def delete(value, %BinaryTree{item: item}=set) when value > item do
    %BinaryTree{
      left: set.left,
      item: set.item,
      right: delete(value, set.right)
    }
  end

  def go() do
    s = 1..10
        |> Enum.shuffle
        |> Enum.reduce(@terminal, &BinaryTree.insert/2)
    IO.puts "Built a set from 1..10 shuffled:"
    IO.inspect s

    IO.puts "Deleting 3"
    IO.inspect delete(3, s)
  end
end
