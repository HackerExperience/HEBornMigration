use Mix.Config

config :heborn_migration,
  namespace: HEBornMigration,
  ecto_repos: [HEBornMigration.Repo]

config :heborn_migration, HEBornMigration.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "olDQeg9L+hxxUdn5QrPJBnDxhu4Kr2cVVEsHGzzeyKABmASbtc2s59pARcUcBxwe",
  render_errors: [view: HEBornMigration.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HEBornMigration.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"
