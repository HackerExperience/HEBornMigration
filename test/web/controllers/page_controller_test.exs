defmodule HEBornMigration.Web.PageControllerTest do
  use HEBornMigration.Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end

  describe "GET /claim" do
    test "succeeds returning json with token", %{conn: conn} do
      conn = get conn, "/claim/username"
      assert %{"token" => _} = json_response(conn, 200)
    end

    test "fails returning json with errors", %{conn: conn} do
      conn = get conn, "/claim/@invalid_username"
      assert %{"errors" => _} = json_response(conn, 422)
    end
  end
end
