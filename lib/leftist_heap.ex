defmodule LeftistHeap do
  @moduledoc """
  Implements a "leftist heap". This is defined as a heap (each node is less
  than all of its children) with the "leftist" property:
    The rank of any left child is at least as large as the rank of its right sibling
  """

  defmodule EmptyHeadException do
    @moduledoc """
    Thrown when peek or pop operations are used on an empty heap.
    """
    defexception message: "Thy head be empty!"
  end

  defstruct left: nil, rank: 0, item: nil, right: nil

  @doc """
  True if this heap contains no items.
  """
  def is_empty?(heap)
  def is_empty?(nil), do: true
  def is_empty?(_), do: false

  @doc """
  Return a new heap containing the provided value.
  """
  def insert(value, heap)
  def insert(value, nil) do
    %LeftistHeap{ item: value }
  end
  def insert(value, heap) do
    merge(insert(value, nil), heap)
  end

  defp rank(nil), do: 0
  defp rank(%LeftistHeap{rank: r}), do: r

  defp build_leftist(x, h1, h2) do
    # To stay leftist, the left sibling rank must not be less than the right sibling rank
    r1 = rank h1
    r2 = rank h2

    if r1 >= r2 do
      %LeftistHeap{
        left: h1,
        rank: r2 + 1, # Rank is right path's rank + 1
        item: x,
        right: h2
      }
    else # Switch up the order to maintain leftism
      %LeftistHeap{
        left: h2,
        rank: r1 + 1, # Rank is right path's rank + 1
        item: x,
        right: h1
      }
    end
  end

  @doc """
  Return a new heap containing the union of elements in the provided heaps.
  """
  def merge(heap, heap)
  def merge(heap, nil), do: heap
  def merge(nil, heap), do: heap
  def merge(
    %LeftistHeap{left: l1, item: x, right: r1}=h1,
    %LeftistHeap{left: l2, item: y, right: r2}=h2
  ) do
    if x <= y do
      # Select the 'X' value for the root of the newly formed heap
      build_leftist(x, l1,
                    merge(r1, h2)) # Merge the first's right child with the second heap
    else
      # Select the right node instead
      build_leftist(y, l2,
                    merge(h1, r2)) # Merge the first heap  with the second's right child
    end
  end


  @doc """
  Return the minimum element of the provided heap.
  """
  def find_min(heap)
  def find_min(nil), do: raise EmptyHeadException
  def find_min(%LeftistHeap{item: item}), do: item

  @doc """
  Return a new heap without the minimum element of the provided heap.
  """
  def delete_min(heap)
  def delete_min(nil), do: raise EmptyHeadException
  def delete_min(%LeftistHeap{left: left, right: right}), do: merge(left, right)

  @doc """
  Given a list, construct a representative leftist heap.
  """
  def from_list(list), do: _from_list(Enum.map(list, &(insert(&1, nil))))
  defp _from_list([]), do: nil
  defp _from_list([result]), do: result
  defp _from_list(list_of_heaps) do
    merged_heaps = Enum.chunk(list_of_heaps, 2, 2, [nil])
                   |> Enum.map(fn [l, r] -> merge(l, r) end)
    _from_list(merged_heaps)
  end
end
