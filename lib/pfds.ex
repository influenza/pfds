defmodule Pfds do
  def go() do
    generate_alias("../cheeses.txt", "../surnames.txt")
  end

  def generate_alias(given_names_file, surnames_file) do
    first_names = File.stream!(given_names_file, [:read, :utf8])
              |> Stream.map(&String.trim/1)
              |> Enum.shuffle # Otherwise we get a degenerate tree
              |> Enum.reduce(%MultiMap{}, &(MultiMap.insert(String.at(&1, 0), &1, &2)))

    surnames = File.stream!(surnames_file, [:read, :utf8])
              |> Stream.map(&String.trim/1)
              |> Enum.shuffle # Otherwise we get a degenerate tree
              |> Enum.reduce(%MultiMap{}, &(MultiMap.insert(String.at(&1, 0), &1, &2)))

    Stream.filter(first_names, &(surname_filter(surnames, &1)))
      |> Enum.reduce([], &(name_builder(surnames, &1, &2)))
      |> Enum.shuffle
      |> Enum.take(5)
      |> Enum.each(&IO.inspect/1)
#Enum.filter_map(first_names, &(surname_filter(surnames, &1)), &(name_builder(surnames, &1, &2)))
#Enum.filter_map(first_names, &(String.first(Enum.at(&1, 0)) == "A"), &(name_builder(surnames, &1, &2)))
#Enum.filter_map(first_names, &(String.first(Enum.at(&1, 0)) == "A"), &IO.inspect/1)
#Enum.filter_map(
#first_names, 
#&(String.first(Enum.at(&1, 0)) == "A"),
#fn (_val) -> IO.puts "wtf mate" end
#)
  end

  def name_builder(surnames, first_name_list, accumulator) do
    first_letter = String.first(Enum.at(first_name_list, 0))
    surnames_for_letter = MultiMap.get_entries(first_letter, surnames)

    names = for f <- first_name_list, l <- surnames_for_letter, do: "#{f} #{l}"

    IO.inspect names
    List.flatten([names | accumulator])
  end

  def surname_filter(surnames, first_name_list) do
    first_letter = String.first(Enum.at(first_name_list, 0))
    MultiMap.has_key?(first_letter, surnames) and Enum.count(MultiMap.get_entries(first_letter, surnames)) > 0
  end


end
