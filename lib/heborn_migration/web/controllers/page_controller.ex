defmodule HEBornMigration.Web.PageController do
  use HEBornMigration.Web, :controller

  alias HEBornMigration.Web.AccountController, as: Controller
  alias HEBornMigration.Web.Account
  alias HEBornMigration.Web.Claim
  alias HEBornMigration.Web.Confirmation
  alias HEBornMigration.Web.EmailController, as: Email

  def get_migrate(conn, _params) do
    changeset = Account.changeset(%Account{}, %{})
    render conn, "index.html", changeset: changeset
  end

  def post_migrate(conn, %{"account" => account}) do
    email = account["email"]
    passw0 = account["password"]
    passw1 = account["password_confirmation"]

    case Controller.migrate(account["token"], email, passw0, passw1) do
      {:ok, account} ->
        email = account.email
        code = account.confirmation.code

        Email.send_confirmation(conn, email, code)

        render conn, "migrated.html", email: email
      {:error, changeset} ->
        render conn, "index.html", changeset: changeset
    end
  end

  def get_confirm(conn, _params) do
    changeset = Ecto.Changeset.cast(%Confirmation{}, %{}, [])
    render conn, "confirm.html", changeset: changeset
  end

  def post_confirm(conn, %{"confirmation" => confirmation}) do
    case Controller.confirm(confirmation["code"]) do
      {:ok, account} ->
        render conn, "confirmed.html", account: account
      {:error, changeset} ->
        render conn, "confirm.html", changeset: changeset
    end
  end

  def claim_by_link(conn, %{"username" => display_name}) do
    case Controller.claim(display_name) do
      {:ok, token} ->
        json conn, %{token: token}
      {:error, changeset} ->
        data = Claim.format_error(changeset)

        conn
        |> put_status(422)
        |> json(%{errors: data})
    end
  end

  def confirm_by_link(conn, %{"code" => code}) do
    case Controller.confirm(code) do
      {:ok, account} ->
        render conn, "confirmed.html", account: account
      {:error, changeset} ->
        render conn, "confirm.html", changeset: changeset
    end
  end
end
