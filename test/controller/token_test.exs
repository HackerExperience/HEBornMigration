defmodule HEBornMigration.Controller.TokenTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Controller.Token

  describe "generate/0" do
    @tag :unit
    test "generates a token with 8 characters" do
      token = Token.generate()
      assert String.length(token) == 8
    end

    @tag heavy: true, timeout: 60_000
    test "generates 600k tokens with a conflict rate lower than 0.5%" do
      token_count = 600_000

      tokens =
        for _ <- 0..token_count,
          do: Token.generate()

      unique_token_count =
        tokens
        |> Enum.uniq()
        |> Enum.count()

      assert 3000 > (token_count - unique_token_count)
    end
  end
end
