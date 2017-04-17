defmodule HEBornMigration.Web.AccountController do
  @moduledoc """
  Provides some map-like functions for working with accounts.
  """

  alias HEBornMigration.Repo
  alias HEBornMigration.Web.Account

  @spec create(
    Account.display_name,
    Account.email,
    Account.password,
    Account.password) ::
      {:ok, Account.t}
      | {:error, Ecto.Changeset.t}
  @doc """
  Creates `Account` with `display_name`, `email`, `password` and
  `password_confirmation`.
  """
  def create(display_name, email, password, password_confirmation) do
    display_name
    |> Account.create(email, password, password_confirmation)
    |> Repo.insert()
  end

  @spec fetch(Account.display_name | Account.username) ::
    {:ok, Account.t}
    | :error
  @doc """
  Fetches `Account` by eitheer its `display_name` or `username`, works
  like `Map.fetch/2`.
  """
  def fetch(username) do
    result =
      username
      |> Account.Query.by_username()
      |> Repo.one()

    case result do
      nil ->
        :error
      account ->
        {:ok, account}
    end
  end

  @spec claimable?(Account.display_name | Account.username) :: boolean
  @doc """
  Returns true if an account for given `username` or `display_name` is
  claimable.
  """
  def claimable?(username) do
    case fetch(username) do
      :error ->
        true
      {:ok, account} ->
        Account.expired?(account)
    end
  end

  @spec delete(Account.t | Account.display_name | Account.username) :: :ok
  @doc """
  Deletes `Account` by either its `username` or struct, works somewhat
  like `Map.delete/2`, but idempotent.
  """
  def delete(account = %Account{}),
    do: delete(account.username)
  def delete(username) do
    username
    |> Account.Query.by_username()
    |> Repo.delete_all()

    :ok
  end
end
