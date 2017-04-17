defmodule HEBornMigration.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :heborn_migration

  plug Plug.Static,
    at: "/", from: :heborn_migration, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_heborn_migration_key",
    signing_salt: "2g4BPKhm"

  plug HEBornMigration.Web.Router

  def load_from_system_env(config) do
    port =
      System.get_env("PORT")
      || raise "expected the PORT environment variable to be set"
    {:ok, Keyword.put(config, :http, [:inet6, port: port])}
  end
end
