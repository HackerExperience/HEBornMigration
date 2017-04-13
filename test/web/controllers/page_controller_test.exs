defmodule HEBornMigration.Web.PageControllerTest do
  use HEBornMigration.Web.ConnCase

  describe "GET /" do
    test "succeeds", %{conn: conn} do
      conn = get conn, "/"
      assert html_response(conn, 200) =~ "Migrate"
    end
  end

  describe "POST /claim" do
    test "succeeds returning json with token", %{conn: conn} do
      conn = post conn, "/claim", [username: "username"]
      assert %{"token" => _} = json_response(conn, 200)
    end

    test "fails returning json with errors", %{conn: conn} do
      conn = post conn, "/claim", [username: "@invalid_username"]
      assert %{"errors" => _} = json_response(conn, 422)
    end
  end
end
