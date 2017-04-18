defmodule NameGenerator do
  @moduledoc """
  Provides a behaviour for loading first and last name files, linking up combinations with the
  same first letter, and retrieving instances of that.
  """

  @callback load_and_map(String.t) :: struct

  @callback generate_aliases(integer, String.t, String.t) :: [String.t]

  @callback get_enumerable(String.t, String.t) :: Enum.t
end
