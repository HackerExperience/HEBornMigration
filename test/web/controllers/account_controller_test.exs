defmodule HEBornMigration.Web.AccountControllerTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Repo
  alias HEBornMigration.Web.AccountController, as: Controller
  alias HEBornMigration.Web.Account
  alias HEBornMigration.Web.Claim
  alias HEBornMigration.Web.Confirmation

  alias HEBornMigration.Factory

  @moduletag :unit

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "claim/1" do
    test "succeeds with valid input" do
      assert {:ok, token} = Controller.claim("example_user")
      assert is_binary(token)
    end

    test "succeeds when reclaiming expired account" do
      now = NaiveDateTime.utc_now()
      two_days_ago = NaiveDateTime.add(now, 60 * 60 * 24 * -3)

      account =
        :account
        |> Factory.build()
        |> Map.put(:inserted_at, two_days_ago)
        |> Repo.insert!()

      assert {:ok, _} = Controller.claim(account.display_name)
    end

    test "returns existing token when already claimed" do
      {:ok, token} = Controller.claim("example_user")
      assert {:ok, ^token} = Controller.claim("example_user")
    end

    test "fails with invalid display_name" do
      assert {:error, %Ecto.Changeset{}} = Controller.claim("&NV@L1|")
    end

    test "fails when user is already migrated" do
      claim = Factory.insert(:claim)
      email = "valid@email.com"
      password = "validpassword"

      {:ok, _} = Controller.migrate(claim, email, password, password)
      {:error, cs} = Controller.claim(claim.display_name)

      assert :display_name in Keyword.keys(cs.errors)
    end
  end

  describe "migrate/3" do
    test "succeeds with valid input" do
      claim = Factory.insert(:claim)

      email = "valid@email.com"
      password = "validpassword"

      result = Controller.migrate(claim, email, password, password)
      assert {:ok, %Account{}} = result
    end

    test "fails with invalid input" do
      claim = Factory.insert(:claim)
      email = "invalid"
      password = "2small"

      result = Controller.migrate(claim, email, password, password)
      assert {:error, %Ecto.Changeset{}} = result
    end
  end

  describe "confirm/1" do
    test "succeeds with valid input" do
      account = Factory.insert(:account)
      confirmed_account = Controller.confirm!(account.confirmation)

      assert confirmed_account.confirmed
    end

    test "raises FunctionClauseError with invalid input" do
      account = Factory.insert(:account)

      Repo.delete!(account.confirmation)
      Repo.delete!(account)

      assert_raise FunctionClauseError, fn ->
        Controller.confirm!(account.confirmation)
      end
    end
  end

  describe "get_claim/1" do
    test "succeeds when claim exists" do
      claim = Factory.insert(:claim)
      assert %Claim{} = Controller.get_claim(claim.token)
    end

    test "fails when claim doesn't exist" do
      refute Controller.get_claim("00000000")
    end
  end

  describe "get_confirmation/1" do
    test "succeeds when confirmation exists" do
      account =
        :account
        |> Factory.insert()
        |> Repo.preload(:confirmation)

      result = Controller.get_confirmation(account.confirmation.code)
      assert %Confirmation{} = result
    end

    test "fails when confirmation doesn't exist" do
      refute Controller.get_confirmation("00000000")
    end
  end
end
