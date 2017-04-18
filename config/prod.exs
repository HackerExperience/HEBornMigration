use Mix.Config

config :heborn_migration, HEBornMigration.Web.Endpoint,
  on_init: {HEBornMigration.Web.Endpoint, :load_from_system_env, []},
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"
