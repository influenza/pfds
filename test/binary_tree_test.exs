defmodule BinaryTreeTest do
  use ExUnit.Case
  doctest BinaryTree

  # Empty
  test "is empty should do only be true for empty trees" do
    not_empty = Enum.reduce([3,4,2], nil, &BinaryTree.insert/2)
    assert !BinaryTree.is_empty? not_empty

    assert BinaryTree.is_empty? nil
  end

  # member
  test "should provide a membership test" do
    %{ false: contents, true: missing } = Enum.group_by 1..10, &(rem(&1, 2) == 0)
    tree = contents |> Enum.shuffle |> Enum.reduce(nil, &BinaryTree.insert/2)
    contents |> Enum.each(fn (entry) ->
      assert BinaryTree.member? entry, tree
    end)
    missing |> Enum.each(fn (entry) ->
      assert !BinaryTree.member? entry, tree
    end)

  end

  # merge
  @doc """
      (5)                         (3)
     /   \    --merged with--    /   \
   (2)   (7)                   (1)   (4)
          -- should result in --

              (5)
             /   \
           (2)   (7)
          /   \
        (1)   (3)
                 \
                 (4)
  """
  test "should merge binary trees" do
    left_tree = [5,2,7] |> Enum.reduce(nil, &BinaryTree.insert/2)
    right_tree = [3,1,4] |> Enum.reduce(nil, &BinaryTree.insert/2)

    expected_tree = [5,2,7,1,3,4] |> Enum.reduce(nil, &BinaryTree.insert/2)

    assert expected_tree == BinaryTree.merge left_tree, right_tree
  end

  # delete
  @doc """
              (5)
             /   \
           (2)   (7)    -- delete (2)
          /   \
        (1)   (3)
                 \
                 (4)

                 -- should result in --

              (5)
             /   \
           (3)   (7)
          /   \
        (1)   (4)
  """
  test "should provide a means to delete items" do
    input = [5,2,7,1,3,4] |> Enum.reduce(nil, &BinaryTree.insert/2)
    expected = [5,3,7,1,4] |> Enum.reduce(nil, &BinaryTree.insert/2)

    assert expected == BinaryTree.delete 2, input
  end

  # reduce
  test "should provide reducing functionality" do
    input = %BinaryTree{
      item: 3,
      right: %BinaryTree{
        left: %BinaryTree{item: 4},
        item: 6,
      }
    }
    expected = [6,4,3]
    assert expected == BinaryTree.reduce input, [], &([ &1 | &2 ])
  end
end
