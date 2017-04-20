defmodule HEBornMigration.Web.PageControllerTest do
  use HEBornMigration.Web.ConnCase, async: true

  alias HEBornMigration.Repo

  alias HEBornMigration.Factory

  @moduletag :integration

  @secret Application.fetch_env!(:heborn_migration, :claim_secret)

  describe "GET /" do
    test "returns the home page", %{conn: conn} do
      conn = get conn, "/"
      assert html_response(conn, 200) =~ "migration process by signing"
    end
  end


  describe "GET /migrate/:token" do
    test "returns the migration page", %{conn: conn} do
      claim = Factory.insert(:claim)
      conn = get conn, "/migrate/#{claim.token}"
      assert html_response(conn, 200) =~ "Welcome back"
    end

    test "returns the home page", %{conn: conn} do
      conn = get conn, "/migrate/potato"
      assert html_response(conn, 200) =~ "expired"
    end
  end

  describe "POST /migrate/:token" do
    test "succeeds returning the migration in progress page", %{conn: conn} do
      claim = Factory.insert(:claim)

      params = %{
        account: %{
          email: "example@email.com",
          password: "12345678",
          password_confirmation: "12345678",
        }
      }

      conn = post(conn, "/migrate/#{claim.token}", params)
      assert html_response(conn, 200) =~ "almost ready!"
    end

    test "fails returning the home page with input errors", %{conn: conn} do
      claim = Factory.insert(:claim)
      params = %{
        account: %{
          email: "",
          password: "",
          password_confirmation: "12345678",
        }
      }

      conn = post(conn, "/migrate/#{claim.token}", params)
      assert html_response(conn, 200) =~ "Migrate"
    end
  end

  describe "GET /confirm" do
    test "returns the confirmation page", %{conn: conn} do
      conn = get conn, "/confirm"
      assert html_response(conn, 200) =~ "Finish your migration by confirming"
    end
  end

  describe "POST /confirm" do
    test "succeeds returning the migration completed page", %{conn: conn} do
      code =
        :account
        |> Factory.insert()
        |> Repo.preload(:confirmation)
        |> Map.fetch!(:confirmation)
        |> Map.fetch!(:code)

      params = %{confirmation: %{code: code}}

      conn = post(conn, "/confirm", params)
      assert html_response(conn, 200) =~ "Your HEBorn account is ready"
    end

    test "fails returning the confirm page with input errors", %{conn: conn} do
      params = %{confirmation: %{code: ""}}

      conn = post(conn, "/confirm", params)
      assert html_response(conn, 200) =~ "Finish your migration by confirming"
    end
  end

  describe "GET /claim/:secret/:username" do
    test "succeeds returning the token", %{conn: conn} do
      conn = get conn, "/claim/#{@secret}/username"
      assert text_response(conn, 200)
    end

    test "fails with 500 code when secret is invalid", %{conn: conn} do
      conn = get conn, "/claim/wat/username"
      assert text_response(conn, 500) =~ "Internal server error"
    end

    test "fails with invalid name", %{conn: conn} do
      conn = get conn, "/claim/#{@secret}/@invalid~username"
      assert text_response(conn, 200) =~ "err"
    end
  end

  describe "GET /confirm/:code" do
    test "succeeds returning the migration completed page", %{conn: conn} do
      code =
        :account
        |> Factory.insert()
        |> Repo.preload(:confirmation)
        |> Map.fetch!(:confirmation)
        |> Map.fetch!(:code)

      conn = get(conn, "/confirm/#{code}")
      assert html_response(conn, 200) =~ "Your HEBorn account is ready"
    end

    test "fails returning the confirm page with input errors", %{conn: conn} do
      conn = get(conn, "/confirm/0")
      assert html_response(conn, 200) =~ "Finish your migration by confirming"
    end
  end
end
