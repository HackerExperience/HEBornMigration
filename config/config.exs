# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :heborn_migration,
  namespace: HEBornMigration,
  ecto_repos: [HEBornMigration.Repo]

# Configures the endpoint
config :heborn_migration, HEBornMigration.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "olDQeg9L+hxxUdn5QrPJBnDxhu4Kr2cVVEsHGzzeyKABmASbtc2s59pARcUcBxwe",
  render_errors: [view: HEBornMigration.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HEBornMigration.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
