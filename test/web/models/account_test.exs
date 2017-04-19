defmodule HEBornMigration.Web.AccountTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Web.Account

  alias HEBornMigration.Factory

  @moduletag :unit

  describe "create/4" do
    test "succeeds with valid fields" do
      display_name = "validusername"
      email = "valid@email.com"
      password = "validpassword"

      cs = Account.create(display_name, email, password, password)
      assert cs.valid?
    end

    test "validate fields" do
      invalid_name = "()&*ç@"
      short_password = "v"
      invalid_email = "invalid.email"

      cs = Account.create(
        invalid_name,
        invalid_email,
        short_password,
        short_password)

      assert :password in Keyword.keys(cs.errors)
      assert :email in Keyword.keys(cs.errors)
      refute cs.valid?

      cs = Account.create(
        invalid_name,
        invalid_email,
        short_password,
        invalid_email)

      assert :password_confirmation in Keyword.keys(cs.errors)
    end
  end

  describe "confirm/1" do
    test "confirms the account" do
      account = Factory.build(:account)
      cs = Account.confirm(account)

      refute account.confirmed
      assert {:ok, true} == Ecto.Changeset.fetch_change(cs, :confirmed)
    end
  end
end
