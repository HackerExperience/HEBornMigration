defmodule HEBornMigration.Web.PageControllerTest do
  use HEBornMigration.Web.ConnCase, async: true

  alias HEBornMigration.Repo
  # alias HEBornMigration.Web.Account

  alias HEBornMigration.Factory

  @moduletag :integration

  def get_token(conn) do
    result =
      conn
      |> get("/claim/username")
      |> json_response(200)

    result["token"]
  end

  describe "GET /" do
    test "returns the home page", %{conn: conn} do
      conn = get conn, "/"
      assert html_response(conn, 200) =~ "Migrate"
    end
  end

  describe "POST /" do
    test "succeeds with valid input", %{conn: conn} do
      token = get_token(conn)

      params = %{
        account: %{
          token: token,
          email: "example@email.com",
          password: "12345678",
          password_confirmation: "12345678",
        }
      }

      conn = post(conn, "/", params)
      assert html_response(conn, 200) =~ "almost ready!"
    end

    test "fails with invalid input", %{conn: conn} do
      params = %{
        account: %{
          token: "",
          email: "",
          password: "",
          password_confirmation: "12345678",
        }
      }

      conn = post(conn, "/", params)
      refute html_response(conn, 200) =~ "almost ready!"
    end
  end

  describe "GET /confirm" do
    test "returns the confirmation page", %{conn: conn} do
      conn = get conn, "/confirm"
      assert html_response(conn, 200) =~ "Confirm your account migration"
    end
  end

  describe "POST /confirm" do
    test "succeeds with valid input", %{conn: conn} do
      code =
        :account
        |> Factory.insert()
        |> Repo.preload(:confirmation)
        |> Map.fetch!(:confirmation)
        |> Map.fetch!(:code)

      params = %{confirmation: %{code: code}}

      conn = post(conn, "/confirm", params)
      assert html_response(conn, 200) =~ "migration completed"
    end

    test "fails with invalid input", %{conn: conn} do
      params = %{confirmation: %{code: ""}}

      conn = post(conn, "/confirm", params)
      refute html_response(conn, 200) =~ "migration completed"
    end
  end

  describe "GET /claim/:username" do
    test "succeeds returning json with token", %{conn: conn} do
      conn = get conn, "/claim/username"
      assert %{"token" => _} = json_response(conn, 200)
    end

    test "fails returning json with errors", %{conn: conn} do
      conn = get conn, "/claim/@invalid~username"
      assert %{"errors" => _} = json_response(conn, 422)
    end
  end

  describe "GET /confirm/:code" do
    test "succeeds with valid input", %{conn: conn} do
      code =
        :account
        |> Factory.insert()
        |> Repo.preload(:confirmation)
        |> Map.fetch!(:confirmation)
        |> Map.fetch!(:code)

      conn = get(conn, "/confirm/#{code}")
      assert html_response(conn, 200) =~ "migration completed"
    end

    test "fails with invalid input", %{conn: conn} do
      conn = get(conn, "/confirm/0")
      refute html_response(conn, 200) =~ "migration completed"
    end
  end
end
