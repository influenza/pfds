defmodule LinkedListTest do
  use ExUnit.Case
  doctest LinkedList

  # Empty
  test "is empty should do only be true for empty lists" do
    not_empty = Enum.reduce([3,4,2], nil, &LinkedList.cons/2)
    assert !LinkedList.is_empty? not_empty

    assert LinkedList.is_empty? nil
  end

  # head
  test "should provide access to the head element" do
    assert_raise LinkedList.EmptyListException, fn () ->
      LinkedList.head(nil)
    end
    list = LinkedList.cons(2, nil)
    assert 2 == LinkedList.head(list)
  end

  # tail
  test "should provide access to the tail of a list" do
    assert_raise LinkedList.EmptyListException, fn () ->
      LinkedList.tail(nil)
    end
    singleton_list = LinkedList.cons(2, nil)
    assert nil == LinkedList.tail(singleton_list)

    two_element_list = LinkedList.cons(1, LinkedList.cons(2, nil))
    assert %LinkedList{item: 2} == LinkedList.tail(two_element_list)
  end

  test "should provide a reversing capability" do
    list = Enum.reduce([1,2,3], nil, &LinkedList.cons/2)
    reversed = Enum.reduce([3,2,1], nil, &LinkedList.cons/2)
    assert reversed == LinkedList.reverse(list)
  end

  test "should provide concatenation" do
    left_list = Enum.reduce([3,4,2], nil, &LinkedList.cons/2)
    right_list = Enum.reduce([7,6,5], nil, &LinkedList.cons/2)

    expected_list = Enum.reduce([7,6,5,3,4,2], nil, &LinkedList.cons/2)

    assert expected_list == LinkedList.concat(left_list, right_list)
  end

  test "should provide an update facility" do
    list = Enum.reduce([3,4,2], nil, &LinkedList.cons/2)
    expected_list = Enum.reduce([3,0,2], nil, &LinkedList.cons/2)

    assert expected_list == LinkedList.update(list, 1, 0)
  end

  test "should provide access to suffixes of the list" do
    list = Enum.reduce([3,2,1], nil, &LinkedList.cons/2)
    expected = Enum.reduce([
         %LinkedList{item: 3},
         %LinkedList{item: 2, next: %LinkedList{item: 3}},
         %LinkedList{item: 1, next: %LinkedList{item: 2, next: %LinkedList{item: 3}}},
       ], nil, &LinkedList.cons/2)

    assert expected == LinkedList.suffixes(list)
  end
end
