use Mix.Config

config :heborn_migration,
  namespace: HEBornMigration,
  ecto_repos: [HEBornMigration.Repo],
  claim_secret: System.get_env("HEBORN_MIGRATION_CLAIM_SECRET")

config :heborn_migration, HEBornMigration.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("HEBORN_MIGRATION_SECRET_KEY_BASE"),
  render_errors: [view: HEBornMigration.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HEBornMigration.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :heborn_migration, HEBornMigration.Web.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("HEBORN_MIGRATION_SMTP_HOST"),
  port: System.get_env("HEBORN_MIGRATION_SMTP_PORT") || 587,
  username: System.get_env("HEBORN_MIGRATION_LOGIN"),
  password: System.get_env("HEBORN_MIGRATION_PASSWORD"),
  tls: :if_available,
  ssl: false,
  retries: 3

config :helf, HELF.Mailer,
  mailers: [HEBornMigration.Web.Mailer],
  default_sender: "contact@hackerexperience.com"

import_config "#{Mix.env}.exs"
