defmodule BinomialHeap do
  @moduledoc """
  Implements a "binomial heap".
  """

  defmodule NilHeapException do
    defexception message: "Nil encountered, expected at least an empty array"
  end

  defmodule EmptyHeapException do
    defexception message: "Empty heap contains no values"
  end

  defmodule NotImplementedException do
    defexception message: "Not yet implemented, sorry!"
  end

  defmodule Tree do
    defstruct rank: 0, item: nil, children: []
  end

  @doc """
  True if this heap contains no items.
  """
  def is_empty?(heap)
  def is_empty?(nil), do: raise NilHeapException
  def is_empty?([]), do: true
  def is_empty?(_), do: false

  defp rank(%Tree{rank: r}), do: r

  @doc """
  Return a new heap containing the provided value.
  """
  def insert(value, heap) do
    insert_tree(%Tree{item: value}, heap)
  end

  defp insert_tree(%Tree{}=tree, []), do: [tree]
  defp insert_tree(%Tree{}=tree, [lowest | rest]=children) do
    if rank(tree) < rank(lowest) do
      [tree | children]
    else
      insert_tree(link(tree, lowest), rest)
    end
  end

  @doc """
  Merge the two provided heaps.
  """
  def merge(heap, heap)
  def merge([], heap), do: heap
  def merge(heap, []), do: heap
  def merge([h1_head | h1_rest]=h1, [h2_head | h2_rest]=h2) do
    cond do
      rank(h1_head) < rank(h2_head) -> [h1_head | merge(h1_rest, h2)]
      rank(h2_head) < rank(h1_head) -> [h2_head | merge(h1, h2_rest)]
      true -> insert_tree(link(h1_head, h2_head), merge(h1_rest, h2_rest))
    end
  end

  defp link(
    %Tree{rank: r, item: x, children: c1}=h1,
    %Tree{rank: r, item: y, children: c2}=h2) do
    if x <= y do
      %Tree {
        rank: r+1,
        item: x, # The lesser value is the new root
        children: [h2 | c1]
      }
    else
      %Tree {
        rank: r+1,
        item: y, # The lesser value is the new root
        children: [h1 | c2]
      }
    end
  end

  @doc """
  Return the minimum element of the provided heap.
  """
  def find_min(heap)
  def find_min(nil), do: raise NilHeapException
  def find_min([]), do: raise EmptyHeapException
  def find_min(heap) do
    { %Tree{item: min}, _ } = remove_min_tree(heap)
    min
  end

  @doc """
  Return a new heap without the minimum element of the provided heap.
  """
  def delete_min(heap)
  def delete_min(nil), do: raise NilHeapException
  def delete_min([]), do: raise EmptyHeapException
  def delete_min(heap) do
    {%Tree{children: c}, rest} = remove_min_tree(heap)
    merge(Enum.reverse(c), rest)
  end

  defp remove_min_tree([t]), do: {t, []}
  defp remove_min_tree([%Tree{item: item}=head | tail]) do
    {%Tree{item: min}=t1, rest} = remove_min_tree(tail)
    if item <= min do
      {head, tail}
    else
      {t1, [head | rest]}
    end
  end
end
