defmodule HEBornMigration.Web.PageController do
  use HEBornMigration.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
