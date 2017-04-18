defmodule CheeseMe do
  @default_count 10

  @name_gen Application.fetch_env!(:cheese_me, :name_generator)

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
    @name_gen.generate_aliases(count, first_names, surnames) |> Enum.each(&IO.puts/1)
  end

  defp print_usage() do
    IO.puts """
    cheese_me --firstnames FIRSTNAMES_FILE --surnames SURNAMES_FILE [--count COUNT]

    Args:
      FIRSTNAMES_FILE Path to a file containing newline separated first names
      SURNAMES_FILE Path to a file containing newline separated surnames
      COUNT optionally specify how many samples to pull. Default: #{@default_count}
    """
  end
end
