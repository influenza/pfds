defmodule MultiMapTestCase do
  use ExUnit.Case
  doctest MultiMap

  test "should provide an empty check" do
    not_empty = [1,2,3] |> Enum.reduce(nil, &(MultiMap.insert(&1, "hi", &2)))

    assert MultiMap.empty? nil
    assert !MultiMap.empty? not_empty
  end

  test "should provide a check for existing keys" do
    keys = ["foo", "bar", "baz"]
    mmap = keys |> Enum.reduce(nil, &(MultiMap.insert(&1, "hi", &2)))

    keys |> Enum.each(fn (key) -> assert MultiMap.has_key? key, mmap end)

    assert !MultiMap.has_key? "skeleton", mmap
  end

  test "should allow value accumulation as a proper multi-map" do
    mmap = MultiMap.insert("hi", "first", %MultiMap{})
    assert ["first"] == MultiMap.get_entries("hi", mmap)

    updated_map = MultiMap.insert("hi", "second", mmap)
    assert ["second", "first"] == MultiMap.get_entries("hi", updated_map)
  end

  test "should merge two multimaps, preserving entries from both" do
    key = "the key"

    left_map = [3,2,1] |> Enum.reduce(nil, &(MultiMap.insert(key, &1, &2)))
    right_map = [6,5,4] |> Enum.reduce(nil, &(MultiMap.insert(key, &1, &2)))

    merged_map = MultiMap.merge(left_map, right_map)

    assert [1,2,3,4,5,6] == MultiMap.get_entries key, merged_map
  end

  test "should provide means to delete keys" do
    keys = ["one", "two", "three"]
    mmap = keys |> Enum.reduce(nil, &(MultiMap.insert(&1, 'val', &2)))

    keys |> Enum.each(fn (key) -> assert MultiMap.has_key? key, mmap end)

    modified_map = MultiMap.delete_key("two", mmap)

    List.delete(keys, "two") |> Enum.each(fn (key) ->
      assert MultiMap.has_key? key, modified_map
    end)

    assert !MultiMap.has_key? "two", modified_map
  end

  test "provide an in-order reduction function" do
    mmap = [1,3,4,2] |> Enum.reduce(nil, &(MultiMap.insert(&1, &1, &2)))

    reducer = fn (%MultiMap.Entry{value: v}, xs) -> [ v | xs] end
    reduced_list = MultiMap.reduce(mmap, [], reducer)

    assert [[4], [3], [2], [1]] == reduced_list
  end

  test "should provide access to entries" do
    mmap = [3,2,1] |> Enum.reduce(nil, &(MultiMap.insert("key", &1, &2)))
    assert [1,2,3] == MultiMap.get_entries "key", mmap
  end

  test "should provide a means to convert a multimap into a list" do
    reducer = fn ({k, v}, mmap) -> MultiMap.insert(k, v, mmap) end
    mmap = (for k <- ['a', 'b', 'c'], v <- [3,2,1], do: {k, v})
      |> Enum.reduce(nil, reducer)

    assert [[1,2,3],[1,2,3],[1,2,3]] == MultiMap.to_list(mmap)
  end
end
