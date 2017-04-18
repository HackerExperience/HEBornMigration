defmodule HEBornMigration.Web.PageController do
  use HEBornMigration.Web, :controller

  alias HEBornMigration.Web.Account
  alias HEBornMigration.Web.Confirmation
  alias HEBornMigration.Web.Service

  @doc """
  The standard index route, features a migration form.
  """
  def get_migrate(conn, _params) do
    changeset = Account.changeset(%Account{}, %{})
    render conn, "index.html", changeset: changeset
  end

  @doc """
  Post route for migrating an account.
  """
  def post_migrate(conn, %{"account" => account}) do
    token = account["token"]
    email = account["email"]
    pass0 = account["password"]
    pass1 = account["password_confirmation"]

    case Service.migrate(token, email, pass0, pass1) do
      {:ok, account} ->
        render conn, "migrated.html", email: account.email
      {:error, changeset} ->
        render conn, "index.html", changeset: changeset
    end
  end

  @doc """
  The confirmation page, features a form for confirmation code input.
  """
  def get_confirm(conn, _params) do
    changeset = Ecto.Changeset.cast(%Confirmation{}, %{}, [])
    render conn, "confirm.html", changeset: changeset
  end

  @doc """
  Post route for confirming an account.
  """
  def post_confirm(conn, %{"confirmation" => confirmation}) do
    case Service.confirm(confirmation["code"]) do
      {:ok, account} ->
        render conn, "confirmed.html", account: account
      {:error, changeset} ->
        render conn, "confirm.html", changeset: changeset
    end
  end

  @doc """
  Claims account by link, used from PHP HE1.
  """
  def claim_by_link(conn, %{"username" => display_name}),
    do: text conn, Service.claim!(display_name)

  @doc """
  Confirms account by link, the link that leads here maybe clicked from some
  email.
  """
  def confirm_by_link(conn, %{"code" => code}) do
    case Service.confirm(code) do
      {:ok, account} ->
        render conn, "confirmed.html", account: account
      {:error, changeset} ->
        render conn, "confirm.html", changeset: changeset
    end
  end
end
