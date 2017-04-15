defmodule Pfds do
  def go() do
    generate_alias(20, "../cheeses.txt", "../surnames.txt")
  end

  def generate_alias(count, given_names_file, surnames_file) do
    first_names = File.stream!(given_names_file, [:read, :utf8])
              |> Stream.map(&String.trim/1)
              |> Enum.shuffle # Otherwise we get a degenerate tree
              |> Enum.reduce(%MultiMap{}, &(MultiMap.insert(String.at(&1, 0), &1, &2)))

    surnames = File.stream!(surnames_file, [:read, :utf8])
              |> Stream.map(&String.trim/1)
              |> Enum.shuffle # Otherwise we get a degenerate tree
              |> Enum.reduce(%MultiMap{}, &(MultiMap.insert(String.at(&1, 0), &1, &2)))

    first_name_list = MultiMap.to_list(first_names)
    Enum.filter(first_name_list, fn (x) -> surname_filter(surnames, x) end)
      |> Enum.reduce([], &(name_builder(surnames, &1, &2)))
      |> Enum.shuffle
      |> Enum.take(count)
      |> Enum.sort
      |> Enum.each(&IO.puts/1)
  end

  defp name_builder(surnames, first_name_list, accumulator) do
    first_letter = String.first(Enum.at(first_name_list, 0))
    surnames_for_letter = MultiMap.get_entries(first_letter, surnames)
    names = for f <- first_name_list, l <- surnames_for_letter, do: "#{f} #{l}"
    List.flatten([names | accumulator])
  end

  defp surname_filter(surnames, first_name_list) do
    first_letter = String.first(Enum.at(first_name_list, 0))
    MultiMap.has_key?(first_letter, surnames)
  end


end
