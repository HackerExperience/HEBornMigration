defmodule HEBornMigration.Controller.AccountTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Controller.Account, as: Controller
  alias HEBornMigration.Model.Account
  alias HEBornMigration.Repo

  alias HEBornMigration.Factory

  @moduletag :unit

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "claim/1" do
    test "succeeds with valid input" do
      assert {:ok, _} = Controller.claim("example_user")
    end

    test "fails with invalid input" do
      assert {:error, %Ecto.Changeset{}} = Controller.claim("&NV@L1|]")
    end

    test "fails when user is already claimed" do
      {:ok, _} = Controller.claim("example_user")
      assert {:error, _} = Controller.claim("example_user")
    end
  end

  describe "migrate/3" do
    test "succeeds with valid input" do
      claim = Factory.insert(:claim)

      email = "valid@email.com"
      password = "validpassword"

      result = Controller.migrate(claim.token, email, password)
      assert {:ok, %Account{}} = result
    end

    test "fails with invalid input" do
      token = "000000000"
      email = "invalid"
      password = "2small"

      result = Controller.migrate(token, email, password)
      assert {:error, %Ecto.Changeset{}} = result
    end
  end
end
