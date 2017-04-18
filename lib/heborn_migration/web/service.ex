defmodule HEBornMigration.Web.Service do
  @moduledoc """
  Provides higher level functionality for claiming, migrating and confirming
  accounts, functions from here are called from the page controller.
  """

  alias HEBornMigration.Repo
  alias HEBornMigration.Web.Account
  alias HEBornMigration.Web.AccountController
  alias HEBornMigration.Web.Claim
  alias HEBornMigration.Web.ClaimController
  alias HEBornMigration.Web.Confirmation
  alias HEBornMigration.Web.ConfirmationController
  alias HEBornMigration.Web.EmailController

  @spec claim(Account.display_name) ::
    {:ok, Claim.token}
    | {:error, Ecto.Changeset.t}
  @doc """
  Tries to claim given account, will override existing migrations if they are
  unconfirmed for more than 48 hours, allowing users to fix wrongly typed
  emails without asking for support.
  """
  def claim(display_name) do
    with :error <- ClaimController.fetch_token(display_name) do
      Repo.transaction(fn -> do_claim(display_name) end)
    end
  end

  def claim!(display_name) do
    case claim(display_name) do
      {:ok, token} ->
        token
      {:error, cs} ->
        errors = Keyword.keys(cs.errors)
        message =
          cond do
            :display_name in errors ->
              "invalid display_name"
            :token in errors ->
              "token collision"
            true ->
              "unknown error"
          end

        raise RuntimeError, message
    end
  end

  @spec migrate(
    Claim.token,
    Account.email,
    Account.password,
    password_confirmation :: Account.password) ::
      {:ok, Account.t}
      | {:error, Ecto.Changeset.t}
  @doc """
  Creates an unconfirmed account for existing claim, this function also sends
  the confirmation email.
  """
  def migrate(token, email, passw0, passw1) do
    Repo.transaction(fn ->
      with \
        {:ok, name} <- ClaimController.fetch_display_name(token),
        :ok <- ClaimController.delete(token),
        {:ok, account} <- AccountController.create(name, email, passw0, passw1),
        confirmation_code = account.confirmation.code,
        {:ok, _} <- EmailController.send_confirmation(email, confirmation_code)
      do
        account
      else
        :error ->
          email
          |> Account.invalid_token_changeset(passw0, passw1)
          |> Repo.rollback()
        {:error, changeset = %Ecto.Changeset{}} ->
          Repo.rollback(changeset)
        _ ->
          raise RuntimeError, "internal error"
      end
    end)
  end

  @spec confirm(Confirmation.code) ::
    {:ok, Account.t}
    | {:error, Ecto.Changeset.t}
  @doc """
  Confirms migrated account, finishes the migration process.
  """
  def confirm(code) do
    Repo.transaction(fn ->
      with \
        {:ok, confirmation} <- ConfirmationController.fetch(code),
        {:ok, confirmation} <- ConfirmationController.confirm(confirmation),
        :ok <- ConfirmationController.delete(confirmation)
      do
        {:ok, confirmation.account}
      else
        :error ->
          code
          |> Confirmation.invalid_code_changeset()
          |> Repo.rollback()
        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @spec do_claim(Account.display_name) ::
    Claim.token
    | no_return
  # this function is called from a transaction within `claim/1`,
  # it just tries to claim an account
  defp do_claim(display_name) do
    with \
      true <- AccountController.claimable?(display_name),
      :ok <- AccountController.delete(display_name),
      {:ok, token} <- ClaimController.create(display_name)
    do
      token
    else
      false ->
        display_name
        |> Claim.unclaimable_changeset()
        |> Repo.rollback()
      {:error, changeset} ->
        Repo.rollback(changeset)
    end
  end
end
