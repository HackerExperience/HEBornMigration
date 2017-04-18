defmodule HEBornMigration.Web.ConfirmationController do
  @moduledoc """
  Provides some map-like functions for working with confirmations.
  """

  alias HEBornMigration.Repo
  alias HEBornMigration.Web.Confirmation

  @spec fetch(Confirmation.code) ::
    {:ok, Confirmation.t}
    | :error
  @doc """
  Fetches `Confirmation` by `code`, works like `Map.fetch/2`.
  """
  def fetch(code) do
    result =
      code
      |> Confirmation.Query.by_code()
      |> Repo.one()

    case result do
      nil ->
        :error
      confirmation ->
        {:ok, confirmation}
    end
  end

  @spec confirm(Confirmation.t) ::
    {:ok, Confirmation.t}
    | {:error, Ecto.Changeset.t}
  @doc """
  Confirms account of `Confirmation`, this function doesn't remove the
  confirmation.
  """
  def confirm(confirmation) do
    confirmation
    |> Repo.preload(:account)
    |> Confirmation.confirm()
    |> Repo.update()
  end

  @spec delete(Confirmation.t | Confirmation.code) :: :ok
  @doc """
  Deletes `Confirmation` by either its `code` or struct, works somwehat
  like `Map.delete/2`, but idempotent.
  """
  def delete(confirmation = %Confirmation{}),
    do: delete(confirmation.code)
  def delete(code) do
    code
    |> Confirmation.Query.by_code()
    |> Repo.delete_all()

    :ok
  end
end
