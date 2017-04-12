defmodule HEBornMigration.Controller.ClaimTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Controller.Claim,
    as: ClaimController
  alias HEBornMigration.Controller.Token
  alias HEBornMigration.Model.Claim
  alias HEBornMigration.Repo

  alias HEBornMigration.Factory

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "request_migration/1" do
    test "succeeds with valid input" do
      result = ClaimController.request_migration("account_name")
      assert {:ok, %Claim{}} = result
    end

    test "fails with invalid input" do
      too_long_name = "abcdefghijklmnopq"

      result = ClaimController.request_migration(too_long_name)
      assert {:error, %Ecto.Changeset{}} = result
    end
  end

  describe "fetch/1" do
    test "succeeds when claim account exists" do
      claim = Factory.insert(:claim)
      result = ClaimController.fetch(claim.token)

      assert %Claim{} = result
    end

    test "fails when claim account doesn't exist" do
      refute ClaimController.fetch(Token.generate())
    end
  end

  describe "finish_migration/1" do
    test "is idempotent" do
      claim = Factory.insert(:claim)

      ClaimController.finish_migration(claim)
      ClaimController.finish_migration(claim)

      refute ClaimController.fetch(claim.token)
    end

    test "succeeds by id" do
      claim = Factory.insert(:claim)

      ClaimController.finish_migration(claim.token)

      refute ClaimController.fetch(claim.token)
    end

    test "succeeds by struct" do
      claim = Factory.insert(:claim)

      ClaimController.finish_migration(claim)

      refute ClaimController.fetch(claim.token)
    end
  end
end
