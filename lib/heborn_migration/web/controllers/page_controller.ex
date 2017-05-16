defmodule HEBornMigration.Web.PageController do
  use HEBornMigration.Web, :controller

  alias HEBornMigration.Web.Account
  alias HEBornMigration.Web.ClaimController
  alias HEBornMigration.Web.Confirmation
  alias HEBornMigration.Web.Service

  @secret Application.fetch_env!(:heborn_migration, :claim_secret)

  @doc """
  The standard index route.
  """
  def index(conn, _params) do
    render conn, "index.html"
  end

  @doc """
  The migrate route, features a migration form.
  """
  def get_migrate(conn, params) do
    token = params["token"]

    case ClaimController.fetch_display_name(token) do
      {:ok, name} ->
        changeset = Account.changeset(%Account{}, %{})
        render conn, "migrate.html",
          changeset: changeset,
          username: name,
          token: token
      _ ->
        render conn, "invalid_claim.html"
    end
  end

  @doc """
  Post route for migrating an account.
  """
  def post_migrate(conn, %{"account" => account, "token" => token}) do
    email = account["email"]
    pass0 = account["password"]
    pass1 = account["password_confirmation"]

    case Service.migrate(token, email, pass0, pass1) do
      {:ok, account} ->
        render conn, "migrated.html", email: account.email
      {:error, changeset} ->
        {:ok, name} = Ecto.Changeset.fetch_change(changeset, :display_name)
        render conn, "migrate.html",
          changeset: changeset,
          username: name,
          token: token
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
  def claim_by_link(conn, %{"username" => display_name, "secret" => secret}) do
    if secret == @secret do
      host = "https://migrate.hackerexperience.com"

      case Service.claim(display_name) do
        {:ok, token} ->
          url = host <> page_path(conn, :post_migrate, token)
          text conn, url
        _ ->
          url = host <> page_path(conn, :claim_error, display_name)
          text conn, url
      end
    else
      conn
      |> put_status(500)
      |> text("Internal server error")
    end
  end

  @doc """
  Default page redirect for claim erorrs.
  """
  def claim_error(conn, params) do
    render conn, "claim_error.html", username: params["username"]
  end

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
