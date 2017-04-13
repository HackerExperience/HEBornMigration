defmodule HEBornMigration.Web.PageController do
  use HEBornMigration.Web, :controller

  alias HEBornMigration.Web.AccountController, as: Controller
  alias HEBornMigration.Web.Account
  alias HEBornMigration.Web.Claim

  def index(conn, _params) do
    changeset = Account.changeset(%Account{}, %{})
    render conn, "index.html", changeset: changeset
  end

  def claim(conn, %{"username" => display_name}) do
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
end
