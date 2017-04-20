defmodule RedBlackTreeTest do
  use ExUnit.Case
  doctest RedBlackTree

  # Empty
  test "is empty should do only be true for empty trees" do
    not_empty = Enum.reduce([3,4,2], nil, &RedBlackTree.insert/2)
    assert !RedBlackTree.is_empty? not_empty

    assert RedBlackTree.is_empty? nil
  end

  # member
  test "should provide a membership test" do
    %{ false: contents, true: missing } = Enum.group_by 1..10, &(rem(&1, 2) == 0)
    tree = contents |> Enum.shuffle |> Enum.reduce(nil, &RedBlackTree.insert/2)
    contents |> Enum.each(fn (entry) ->
      assert RedBlackTree.member? entry, tree
    end)
    missing |> Enum.each(fn (entry) ->
      assert !RedBlackTree.member? entry, tree
    end)
  end

  test "should not locate keys in an empty tree" do
    assert !RedBlackTree.member? "not here", nil
  end

  # balancing
  test "should maintain balance" do
    # This would cause a degenerate tree - a linked-list - in an unbalanced tree
    tree = [0] |> Enum.reduce(nil, &RedBlackTree.insert/2)
    assert 1 == RedBlackTree.depth(tree)
    tree = 0..2 |> Enum.reduce(nil, &RedBlackTree.insert/2)
    assert 2 == RedBlackTree.depth(tree)
    tree = 0..4 |> Enum.reduce(nil, &RedBlackTree.insert/2)
    assert 3 == RedBlackTree.depth(tree)
    tree = 0..8 |> Enum.reduce(nil, &RedBlackTree.insert/2)
    assert 4 == RedBlackTree.depth(tree)
    tree = 0..16 |> Enum.reduce(nil, &RedBlackTree.insert/2)
    assert 5 == RedBlackTree.depth(tree)
  end

  #######################
  # Enumerable protocol #
  #######################

  test "should be a proper enumerable" do
    cons = &([&1 | &2])
    range = 1..10

    tree = range |> Enum.reduce(nil, &RedBlackTree.insert/2)
    from_tree = tree |> Enum.reduce([], cons)
    from_range = range |> Enum.reduce([], cons)

    assert from_tree == from_range
  end

  test "should be mappable via enumerable" do
    range = 1..10
    mapped_from_tree = range
                       |> Enum.reduce(nil, &RedBlackTree.insert/2)
                       |> Enum.map(&Integer.to_string/1)
    mapped_from_range = range |> Enum.map(&Integer.to_string/1)
    assert mapped_from_tree == mapped_from_range
  end

  test "should support the 'in' keyword" do
    range = 1..10
    outside_range = 11..20
    tree = range |> Enum.reduce(nil, &RedBlackTree.insert/2)
    range |> Enum.each(fn (item) -> assert item in tree end)
    outside_range |> Enum.each(fn (item) -> assert !(item in tree) end)
  end

  test "should support length checking" do
    sizes = 1..10
    size_to_tree = fn (size) -> Enum.reduce(1..size, nil, &RedBlackTree.insert/2) end
    Enum.zip(sizes, Enum.map(sizes, size_to_tree))
      |> Enum.each(fn {size, tree} -> assert size == Enum.count(tree) end)
  end

  test "should support halting enumeration" do
    tree = 1..100 |> Enum.reduce(nil, &RedBlackTree.insert/2)
    expected = 1 + 2 + 3
    actual = Enum.reduce_while(tree, 0, fn i, acc ->
      if i < 4, do: {:cont, acc + i}, else: {:halt, acc} end)
    assert expected == actual
  end

  test "should support suspending" do
    number_tree = [1,2,3] |> Enum.reduce(nil, &RedBlackTree.insert/2)
    # Stream zipping should require suspend to work
    result = Stream.zip([number_tree, Stream.cycle(["a", "b"])]) |> Enum.take(3)
    assert result == [
      {1, "a"},
      {2, "b"},
      {3, "a"},
    ]
  end
end
