defmodule LeftistHeapTest do
  use ExUnit.Case
  doctest LeftistHeap

  test "find min should return the smallest item" do
    heap = Enum.reduce([3,4,5,2,1,9,4,3], nil, &LeftistHeap.insert/2)
    assert 1 == LeftistHeap.find_min(heap)
  end

  test "delete min should return a new heap without the previous minimum" do
    heap = Enum.reduce([3,4,5,2,1], nil, &LeftistHeap.insert/2)
    assert 1 == LeftistHeap.find_min(heap)
    heap = LeftistHeap.delete_min(heap)
    assert 2 == LeftistHeap.find_min(heap)
    heap = LeftistHeap.delete_min(heap)
    assert 3 == LeftistHeap.find_min(heap)
  end

  test "is empty should do only be true for empty heaps" do
    not_empty = Enum.reduce([3,4,2], nil, &LeftistHeap.insert/2)
    assert !LeftistHeap.is_empty? not_empty

    assert LeftistHeap.is_empty? nil
  end
end
