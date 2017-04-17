defmodule HEBornMigration.Web.ClaimTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Web.Claim

  describe "create/1" do
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
