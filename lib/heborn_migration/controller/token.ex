defmodule HEBornMigration.Controller.Token do
  @moduledoc """
  Unique Token generator, it's not suitable for UUID as it uses a PRNG
  algorithm, but it's suitable to be used for PIN generation.

  It's proven to cause no conflicts for 1kk tokens.
  """

  @token_length 10

  @token_characters \
    '1234567890ABCDEFGHIJKLMNPQRSTUVWXYZ'
    |> Enum.map(&([&1]))
    |> Enum.with_index()

  @charnum_cache Enum.count(@token_characters)

  @spec generate :: String.t
  @doc """
  Generates a random token of `@token_length`'s length containing characters
  from `@token_characters`.
  """
  def generate,
    do: :erlang.list_to_binary(random_number_list())

  @spec random_number_list :: [pos_integer]
  # uses a PRNG algorithm as it will just generate ~600k tokens
  defp random_number_list do
    for _ <- 1..@token_length do
      (:rand.uniform() * @charnum_cache)
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
