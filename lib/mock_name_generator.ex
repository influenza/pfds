defmodule MockNameGenerator do
  @behaviour NameGenerator

  @moduledoc """
  Provides a behaviour for loading first and last name files, linking up combinations with the
  same first letter, and retrieving instances of that.
  """

  def load_and_map(_file) do
    %{}
  end

  def generate_aliases(count, _file_one, _file_two) do
    1..count |> Enum.reduce([], fn (x, xs) -> [x | xs] end)
  end

  def get_enumerable(_file_one, _file_two) do
    ['flowy fan']
  end
end
