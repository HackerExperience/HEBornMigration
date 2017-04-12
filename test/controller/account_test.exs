defmodule HEBornMigration.Controller.AccountTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Controller.Account, as: AccountController
  alias HEBornMigration.Model.Account
  alias HEBornMigration.Repo

  alias HEBornMigration.Factory

  @moduletag :unit

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "create/3" do
    test "succeeds with valid input" do
      claim = Factory.insert(:claim)

      email = "valid@email.com"
      password = "validpassword"

      result = AccountController.create(claim, email, password)
      assert {:ok, %Account{}} = result
    end

    test "fails with invalid input" do
      claim = Factory.insert(:claim)

      email = "invalid"
      password = "2small"

      result = AccountController.create(claim, email, password)
      assert {:error, %Ecto.Changeset{}} = result
    end
  end

  describe "fetch/1" do
    test "succeeds with valid input" do
      account = Factory.insert(:account)
      assert %Account{} = AccountController.fetch(account.id)
    end

    test "fails when account doesn't exist" do
      refute AccountController.fetch(-1)
    end
  end

  describe "fetch_by_username/1" do
    test "succeeds with valid input" do
      account = Factory.insert(:account)
      assert %Account{} = AccountController.fetch_by_username(account.username)
    end

    test "fails when account doesn't exist" do
      refute AccountController.fetch_by_username("invalid")
    end
  end

  describe "confirm/1" do
    test "succeeds with valid input" do
      account = Factory.insert(:account)
      assert {:ok, %Account{}} = AccountController.confirm(account)
    end
  end
end
