defmodule LinkedList do
  @moduledoc """
  Reference implementation of a linked list.
  """

  defstruct [:item, :next]

  @terminal_node %{item: nil, next: nil}


  @doc """
  True if this list does not contain anything
  """
  def is_empty?(@terminal_node), do: true
  def is_empty?(_), do: false

  def head(%LinkedList{item: item}) do
    item
  end

  def tail(%LinkedList{ next: tail}) do
    tail
  end

  def cons(item, list) do
    %LinkedList {
      item: item,
      next: list
    }
  end

  def reverse(@terminal_node), do: @terminal_node #empty list
  def reverse(%LinkedList{next: @terminal_node, item: _}=end_node) do
    # reverse of single element list is isomorphic
    end_node
  end
  def reverse(%LinkedList{}=node) do
    # general case, reversed list is the reversed tail + the head
    concat(
           reverse(tail(node)),
           cons(head(node), @terminal_node)
     )
  end

  def concat(@terminal_node, right) do
    right
  end
  def concat(left, right) do
    cons(head(left), concat(tail(left), right))
  end

  def update(@terminal_node, _, _), do: @terminal_node
  def update(%LinkedList{next: next}, 0, value) do
    cons(value, next)
  end

  def update(list, index, item) do
    cons(
         head(list), update(tail(list), index - 1, item)
     )
  end

  def suffixes(@terminal_node), do: cons(@terminal_node, @terminal_node)
  def suffixes(list) do
    cons(list, suffixes(tail(list)))
  end

  def go() do
    l = Enum.reduce(1..10, %LinkedList{}, fn (x, acc) -> LinkedList.cons(x, acc) end)
    IO.puts "Head of this thing is #{head(l)}"
    IO.puts "Tail of this thing:"
    IO.inspect tail(l)
    IO.puts "Cons a snake:"
    IO.inspect cons("a snake", l)

    IO.puts "Reversed is: "
    IO.inspect reverse(l)

    IO.puts "Updating index 3 to 'third'"
    IO.inspect update(l, 3, "third")

    IO.puts "Reversing and updating index 3 to 'third'"
    IO.inspect update(reverse(l), 3, "third")

    IO.puts "Suffixes of [1,2,3,4] list:"
    IO.inspect suffixes(Enum.reduce(
                        4..1,
                        @terminal_node,
                        &LinkedList.cons/2))
  end
end
