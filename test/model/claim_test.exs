defmodule HEBornMigration.Model.ClaimTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Model.Claim

  describe "create/2" do
    test "succeeds with valid input" do
      cs = Claim.create("Example")

      assert cs.valid?
    end

    test "fails with invalid display_name" do
      too_long_name = "abcdefghijklmnopq"
      cs = Claim.create(too_long_name)

      assert :display_name in Keyword.keys(cs.errors)
      refute cs.valid?
    end
  end
end
