defmodule Pfds do
  @default_count 10

  def main(args) do
    { opts, _, _} = OptionParser.parse(args,
           switches: [firstnames: :string, surnames: :string, count: :integer])

    first_names = opts[:firstnames]
    surnames = opts[:surnames]
    if first_names == nil or surnames == nil do
      print_usage()
      exit {:shutdown, 1}
    end

    count = case opts[:count] do
      nil -> @default_count
      x -> x
    end
    generate_alias(count, first_names, surnames)
  end

  defp print_usage() do
    IO.puts """
    pfds --firstnames FIRSTNAMES_FILE --surnames SURNAMES_FILE [--count COUNT]

    Args:
      FIRSTNAMES_FILE Path to a file containing newline separated first names
      SURNAMES_FILE Path to a file containing newline separated surnames
      COUNT optionally specify how many samples to pull. Default: #{@default_count}
    """
  end

  def load_and_map(file) do
    File.stream!(file, [:read, :utf8])
    |> Stream.map(&String.trim/1)
    |> Enum.shuffle # Otherwise we get a degenerate tree
    |> Enum.reduce(%MultiMap{}, &(MultiMap.insert(String.at(&1, 0), &1, &2)))
  end

  def generate_alias(count, given_names_file, surnames_file) do
    first_names = load_and_map(given_names_file)
    surnames = load_and_map(surnames_file)

    first_name_list = MultiMap.to_list(first_names)
    print_alias(first_name_list, surnames, count)
  end

  def get_alias_enumerable(first_name_list, surnames) do
     Stream.filter(first_name_list, fn (x) -> surname_filter(surnames, x) end)
      |> Enum.reduce([], &(name_builder(surnames, &1, &2)))
  end

  def print_alias(first_name_list, surnames, count) do
     Enum.filter(first_name_list, fn (x) -> surname_filter(surnames, x) end)
      |> Enum.reduce([], &(name_builder(surnames, &1, &2)))
      |> Enum.shuffle
      |> Enum.take(count)
      |> Enum.sort
      |> Enum.each(&IO.puts/1)
  end

  def pull_alias(first_name_list, surnames, count) do
     Enum.filter(first_name_list, fn (x) -> surname_filter(surnames, x) end)
      |> Enum.reduce([], &(name_builder(surnames, &1, &2)))
      |> Enum.shuffle
      |> Enum.take(count)
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
