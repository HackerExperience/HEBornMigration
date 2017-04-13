defmodule HEBornMigration.Web.PageController do
  use HEBornMigration.Web, :controller

  alias HEBornMigration.Controller.Account, as: AccountController
  alias HEBornMigration.Model.Claim

  def index(conn, _params) do
    render conn, "index.html"
  end

  def claim(conn, params) do
    display_name = Map.fetch!(params, "display_name")

    case AccountController.claim(display_name) do
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
