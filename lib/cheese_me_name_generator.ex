defmodule CheeseMeNameGenerator do
  @behaviour NameGenerator

  @moduledoc """
  Provides a behaviour for loading first and last name files, linking up combinations with the
  same first letter, and retrieving instances of that.
  """

  @doc """
  Load the specified file into a MultiMap keyed on the first letter of the entry.
  The provided file should have one entry per line.
  """
  def load_and_map(file) do
    File.stream!(file, [:read, :utf8])
    |> Stream.map(&String.trim/1)
    |> Enum.shuffle # Otherwise we get a degenerate tree
    |> Enum.reduce(%MultiMap{}, &(MultiMap.insert(String.at(&1, 0), &1, &2)))
  end


  @doc """
  Grab "count" random aliases from the provided first and last name files.
  """
  def generate_aliases(count, given_names_file, surnames_file) do
    get_enumerable(given_names_file, surnames_file)
      |> Enum.take(count)
      |> Enum.sort
  end


  @doc """
  Get an enumerable to the collection of possible aliases.
  """
  def get_enumerable(given_names_file, surnames_file) do
    first_names = load_and_map(given_names_file)
    surnames = load_and_map(surnames_file)

    first_name_list = MultiMap.to_list(first_names)

    Enum.filter(first_name_list, fn (x) -> surname_filter(surnames, x) end)
      |> Enum.reduce([], &(name_builder(surnames, &1, &2)))
      |> Enum.shuffle
  end

  defp name_builder(surnames, first_name_list, accumulator) do
    first_letter = String.first(Enum.at(first_name_list, 0))
    surnames_for_letter = MultiMap.get_entries(first_letter, surnames)
    names = for f <- first_name_list, l <- surnames_for_letter, do: "#{f} #{l}"
    List.flatten([names | accumulator])
  end

  defp surname_filter(_surnames, nil), do: false
  defp surname_filter(_surnames, []), do: false
  defp surname_filter(surnames, first_name_list) do
    first_letter = String.first(Enum.at(first_name_list, 0))
    MultiMap.has_key?(first_letter, surnames)
  end

end
