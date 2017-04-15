defmodule BinomialHeap do
  @moduledoc """
  Implements a "binomial heap".
  """

  defmodule NotImplementedException do
    defexception message: "Not yet implemented, sorry!"
  end

  defmodule EmptyHeadException do
    defexception message: "Empty structure provided"
  end

  defstruct rank: 0, item: nil, children: []

  @doc """
  True if this heap contains no items.
  """
  def is_empty?(heap)
  def is_empty?(nil), do: true
  def is_empty?(_), do: false

  @doc """
  Return a new heap containing the provided value.
  """
  def insert(_value, _heap), do: raise NotImplementedException

  @doc """
  Return the minimum element of the provided heap.
  """
  def find_min(heap)
  def find_min(nil), do: raise EmptyHeadException
  def find_min(_heap), do: raise NotImplementedException

  @doc """
  Return a new heap without the minimum element of the provided heap.
  """
  def delete_min(heap)
  def delete_min(nil), do: raise EmptyHeadException
  def delete_min(_heap), do: raise NotImplementedException
end
