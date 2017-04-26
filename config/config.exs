use Mix.Config

# logger configs
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# repo configs
config :heborn_migration, HEBornMigration.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("HEBORN_MIGRATION_DB_USERNAME") || "postgres",
  password: System.get_env("HEBORN_MIGRATION_DB_PASSWORD") || "postgres",
  hostname: System.get_env("HEBORN_MIGRATION_DB_HOST") ||"localhost"

# project namespace and repos
config :heborn_migration,
  namespace: HEBornMigration,
  ecto_repos: [HEBornMigration.Repo]

# smtp mailer config
config :heborn_migration, HEBornMigration.Web.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("HEBORN_MIGRATION_SMTP_HOST"),
  port: System.get_env("HEBORN_MIGRATION_SMTP_PORT") || 587,
  username: System.get_env("HEBORN_MIGRATION_SMTP_LOGIN"),
  password: System.get_env("HEBORN_MIGRATION_SMTP_PASSWORD"),
  tls: :if_available,
  ssl: false,
  retries: 3

# phoenix endpoint config
config :heborn_migration, HEBornMigration.Web.Endpoint,
  secret_key_base: System.get_env("HEBORN_MIGRATION_SECRET_KEY_BASE"),
  render_errors: [view: HEBornMigration.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HEBornMigration.PubSub,
           adapter: Phoenix.PubSub.PG2]

# import env-specific configs
import_config "#{Mix.env}.exs"
