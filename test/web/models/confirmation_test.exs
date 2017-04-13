defmodule HEBornMigration.Web.ConfirmationTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Web.Confirmation

  alias HEBornMigration.Factory

  describe "create/0" do
    test "returns confirmation" do
      assert %Confirmation{} = Confirmation.create()
    end
  end

  describe "confirm/1" do
    test "returns changeset" do
      account = Factory.build(:account)
      confirmation = Map.put(account.confirmation, :account, account)

      assert %Ecto.Changeset{} = Confirmation.confirm(confirmation)
    end
  end
end
