defmodule HEBornMigration.Controller.Account do

  alias HEBornMigration.Model.Account
  alias HEBornMigration.Model.Claim
  alias HEBornMigration.Model.Confirmation
  alias HEBornMigration.Repo

  @spec claim(display_name :: String.t) ::
    {:ok, token :: String.t}
    | {:error, Ecto.Changeset.t}
  @doc """
  Claims account with given `display_name`, returns a token string to be
  used for migration.

  Reclaiming an unconfirmed account is possible after 48 hours, this feature
  allows players that typed wrong emails to retry their migrations.
  """
  def claim(display_name) do
    changeset = Claim.create(display_name)

    with \
      nil <- Repo.get_by(Claim, display_name: display_name),
      nil <- Repo.get_by(Account, username: String.downcase(display_name)),
      {:ok, claim} <- Repo.insert(changeset)
    do
      {:ok, claim.token}
    else
      {:error, changeset} ->
        {:error, changeset}

      claim = %Claim{} ->
        {:ok, claim.token}

      account = %Account{} ->
        account
        |> Account.expired?()
        |> maybe_expire_account(account, changeset)
    end
  end

  @spec migrate(Claim.t, email :: String.t, password :: String.t) ::
    {:ok, Account.t}
    | {:error, Ecto.Changeset.t}
  @doc """
  Migrates claimed account, sends an e-mail with the confirmation code.
  """
  def migrate(claim, email, password) do
    Repo.transaction fn ->
      Repo.delete!(claim)

      result =
        claim
        |> Account.create(email, password)
        |> Repo.insert()

      case result do
        {:ok, account} ->
          account
        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end
  end

  @spec confirm!(Confirmation.t) ::
    Account.t
  @doc """
  Confirms an already migrated account.

  The expiration date doesn't affect this function, as it's just intented to
  help users that wrongly typed their emails.
  """
  def confirm!(confirmation) do
    {:ok, account} =
      Repo.transaction fn ->
        confirmation =
          confirmation
          |> Repo.preload(:account)
          |> Confirmation.confirm()
          |> Repo.update!()

        Repo.delete!(confirmation)

        confirmation.account
      end

    account
  end

  @spec get_claim(Claim.token) ::
    Claim.t
    | nil
  @doc """
  Gets a `Claim` by its `token`.
  """
  def get_claim(token),
    do: Repo.get(Claim, token)

  @spec get_confirmation(Confirmation.code) ::
    Confirmation.t
    | nil
  @doc """
  Gets a `Confirmation` by its `code`.
  """
  def get_confirmation(code),
    do: Repo.get(Confirmation, code)

  # replaces an expired unconfirmed account
  @spec maybe_expire_account(expire? :: boolean, Account.t, Ecto.Changeset.t) ::
    {:ok, Claim.token}
    | {:error, Ecto.Changeset.t}
  defp maybe_expire_account(true, account, changeset) do
    Repo.transaction fn ->
      Repo.delete!(account)

      case Repo.insert(changeset) do
        {:ok, claim} ->
          claim.token
        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end
  end
  defp maybe_expire_account(false, _, changeset)  do
    changeset = Ecto.Changeset.add_error(
      changeset,
      :display_name,
      "has been taken")

    {:error, changeset}
  end
end
