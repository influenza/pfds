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

  def member(value, %BinaryTree{item: item}=set) when value < item do
    member(value, set.left)
  end
  def member(value, %BinaryTree{item: item}=set) when value > item do
    member(value, set.right)
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

  def go() do
    s = 1..10
        |> Enum.shuffle
        |> Enum.reduce(@terminal, &BinaryTree.insert/2)
    IO.puts "Built a set from 1..10 shuffled:"
    IO.inspect s
  end
end
