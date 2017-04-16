defmodule LinkedList do
  @moduledoc """
  Reference implementation of a linked list.
  """

  defmodule EmptyListException do
    defexception message: "The list is empty"
  end

  defstruct [:item, :next]

  @doc """
  True if this list does not contain anything
  """
  def is_empty?(list)
  def is_empty?(nil), do: true
  def is_empty?(_), do: false

  @doc """
  Retrieve the item at the head of this list. Raises EmptyListException if
  the list is empty.
  """
  def head(list)
  def head(nil), do: raise EmptyListException
  def head(%LinkedList{item: item}), do: item

  @doc """
  Retrieve tail of this list. Raises EmptyListException if the list is empty.
  """
  def tail(list)
  def tail(nil), do: raise EmptyListException
  def tail(%LinkedList{next: tail}), do: tail

  @doc """
  Construct a new list with a head of the provided item and a tail of the 
  provided list.
  """
  def cons(item, list), do: %LinkedList{item: item, next: list }

  @doc """
  Reverse the provided list.
  """
  def reverse(list)
  def reverse(nil), do: nil
  def reverse(%LinkedList{next: nil, item: _}=end_node) do
    # reverse of single element list is isomorphic
    end_node
  end
  def reverse(%LinkedList{}=node) do
    # general case, reversed list is the reversed tail + the head
    concat(
           reverse(tail(node)),
           cons(head(node), nil)
     )
  end


  @doc """
  Return a list containing the elements of the left list followed by the right.
  """
  def concat(left, right)
  def concat(nil, right), do: right
  def concat(left, right), do: cons(head(left), concat(tail(left), right))

  @doc """
  Build a list resembling the provided list, excepting the item at index `index` is
  instead the provided value.

  For instance:
    update(['a', 'b', 'c'], 1, 'x') -> ['a', 'x', 'c']
  """
  def update(list, index, value)
  def update(nil, _, _), do: nil
  def update(%LinkedList{next: next}, 0, value), do: cons(value, next)
  def update(list, index, item) do
    cons(
         head(list),
         update(tail(list), index - 1, item)
     )
  end

  @doc """
  Build a list of all suffixes of the provided list.

  For instance:
    suffixes([1, 2, 3, 4]) -> [[1, 2, 3, 4], [2, 3, 4], [3, 4], [4]]
  """
  def suffixes(list)
  def suffixes(nil), do: nil
  def suffixes(list), do: cons(list, suffixes(tail(list)))
end
