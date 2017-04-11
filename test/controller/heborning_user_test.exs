defmodule HEBornMigration.Controller.HEBorningUserTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Controller.HEBorningUser,
    as: HEBorningUserController
  alias HEBornMigration.Controller.Token
  alias HEBornMigration.Model.HEBorningUser
  alias HEBornMigration.Repo

  alias HEBornMigration.Factory

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "request_migration/1" do
    test "succeeds with valid input" do
      result = HEBorningUserController.request_migration("account_name")
      assert {:ok, %HEBorningUser{}} = result
    end

    test "fails with invalid input" do
      too_long_name = "abcdefghijklmnopq"

      result = HEBorningUserController.request_migration(too_long_name)
      assert {:error, %Ecto.Changeset{}} = result
    end
  end

  describe "fetch/1" do
    test "succeeds when heborning account exists" do
      heborning = Factory.insert(:heborning_user)
      result = HEBorningUserController.fetch(heborning.token)

      assert %HEBorningUser{} = result
    end

    test "fails when heborning account doesn't exist" do
      refute HEBorningUserController.fetch(Token.generate())
    end
  end

  describe "finish_migration/1" do
    test "is idempotent" do
      heborning = Factory.insert(:heborning_user)

      HEBorningUserController.finish_migration(heborning)
      HEBorningUserController.finish_migration(heborning)

      refute HEBorningUserController.fetch(heborning.token)
    end

    test "succeeds by id" do
      heborning = Factory.insert(:heborning_user)

      HEBorningUserController.finish_migration(heborning.token)

      refute HEBorningUserController.fetch(heborning.token)
    end

    test "succeeds by struct" do
      heborning = Factory.insert(:heborning_user)

      HEBorningUserController.finish_migration(heborning)

      refute HEBorningUserController.fetch(heborning.token)
    end
  end
end
