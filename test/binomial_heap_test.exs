defmodule BinomialHeapTest do
  use ExUnit.Case
  doctest BinomialHeap

  # Empty
  test "is empty should do only be true for empty trees" do
    not_empty = [1,2,3] |> Enum.reduce([], &BinomialHeap.insert/2)
    assert !BinomialHeap.is_empty? not_empty

    assert BinomialHeap.is_empty? []

    assert_raise BinomialHeap.NilHeapException, fn () -> BinomialHeap.is_empty? nil end
  end

  # insert
  test "should maintain th structure during insertions" do
    rank0 = BinomialHeap.insert(0, [])
    rank1 = (1..2)  |> Enum.reduce([], &BinomialHeap.insert/2)
    rank2 = (1..4)  |> Enum.reduce([], &BinomialHeap.insert/2)
    rank3 = (1..8)  |> Enum.reduce([], &BinomialHeap.insert/2)
    rank4 = (1..16) |> Enum.reduce([], &BinomialHeap.insert/2)

    assert Enum.at(rank0, 0).rank == 0
    assert Enum.at(rank1, 0).rank == 1
    assert Enum.at(rank2, 0).rank == 2
    assert Enum.at(rank3, 0).rank == 3
    assert Enum.at(rank4, 0).rank == 4
  end

  # find min
  test "should allow a means to find the minimum" do
    heap = (1..70) |> Enum.shuffle |> Enum.reduce([], &BinomialHeap.insert/2)
    assert BinomialHeap.find_min(heap) == 1
  end

  # delete min
  test "should allow the removal of a minimum value" do
    range = (1..70)
    heap = range |> Enum.shuffle |> Enum.reduce([], &BinomialHeap.insert/2)
    range |> Enum.reduce(heap, fn (item, acc) ->
      assert BinomialHeap.find_min(acc) == item
      BinomialHeap.delete_min(acc)
    end)
  end

  # merge
  test "should allow merging of two heaps" do
    left = (1..8) |> Enum.reduce([], &BinomialHeap.insert/2)
    right = (1..8) |> Enum.map(&(&1 + 8)) |> Enum.reduce([], &BinomialHeap.insert/2)

    result = BinomialHeap.merge(left, right)
    assert Enum.at(result, 0).rank == 4
  end
end
