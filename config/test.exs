use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :heborn_migration, HEBornMigration.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :heborn_migration, HEBornMigration.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "heborn_migration_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :helf, HELF.Mailer,
  mailers: [HEBornMigration.TestMailer],
  default_sender: "noreply@hackerexperience.com"

config :heborn_migration, HEBornMigration.TestMailer,
  adapter: Bamboo.TestAdapter
