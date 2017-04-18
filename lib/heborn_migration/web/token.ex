defmodule HEBornMigration.Web.Token do
  @moduledoc """
  Unique Token generator, it's not suitable for UUID as it uses a PRNG
  algorithm, but it's suitable to be used for PIN generation.

  It's proven to cause no conflicts for 1kk tokens.
  """

  @token_characters \
    '1234567890abcdefghijklmnopqrstuvwxyz'
    |> Enum.map(&([&1]))
    |> Enum.with_index()

  @charcode_cache Enum.count(@token_characters)

  @spec generate(pos_integer) :: String.t
  @doc """
  Generates a random token of given length containing characters
  from `@token_characters`.
  """
  def generate(length \\ 10),
    do: :erlang.list_to_binary(random_number_list(length))

  @spec random_number_list(pos_integer) :: [pos_integer]
  # uses a PRNG algorithm as it will just generate ~600k tokens
  defp random_number_list(length) do
    for _ <- 1..length do
      (:rand.uniform() * @charcode_cache)
      |> Float.floor()
      |> trunc()
      |> to_token_character()
    end
  end

  # converts number to character from @token_characters
  for {char, index} <- @token_characters do
    defp to_token_character(unquote(index)),
      do: unquote(char)
  end
end
