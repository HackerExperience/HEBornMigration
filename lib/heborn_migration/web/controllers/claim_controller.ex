defmodule HEBornMigration.Web.ClaimController do
  @moduledoc """
  Provides some map-like functions for working with claims.
  """

  alias HEBornMigration.Repo
  alias HEBornMigration.Web.Account
  alias HEBornMigration.Web.Claim

  import Ecto.Query, only: [select: 3]

  @spec create(Account.display_name) ::
    {:ok, Claim.token}
    | {:error, Ecto.Changeset.t}
  def create(display_name) do
    result =
      display_name
      |> Claim.create()
      |> Repo.insert()

    case result do
      {:ok, claim} ->
        {:ok, claim.token}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @spec fetch_token(Account.display_name) ::
    {:ok, Claim.token}
    | :error
  @doc """
  Fetches `Claim.token` by `display_name`, works like `Map.fetch/2`.
  """
  def fetch_token(display_name) do
    result =
      display_name
      |> Claim.Query.by_display_name()
      |> select([c], c.token)
      |> Repo.one()

    case result do
      nil ->
        :error
      token ->
        {:ok, token}
    end
  end

  @spec fetch_display_name(Claim.token) ::
    {:ok, Account.display_name}
    | :error
  @doc """
  Fetches claim's `Account.display_name` by `display_name`, works like
  `Map.fetch/2`.
  """
  def fetch_display_name(token) do
    result =
      token
      |> Claim.Query.by_token()
      |> select([c], c.display_name)
      |> Repo.one()

    case result do
      nil ->
        :error
      display_name ->
        {:ok, display_name}
    end
  end

  @spec delete(token ::  Claim.token) :: :ok
  @doc """
  Deletes `Claim` by its `token`, works somwhat like `Map.delete/2`, but it's
  idempotent.
  """
  def delete(token) do
    token
    |> Claim.Query.by_token()
    |> Repo.delete_all()

    :ok
  end
end
