use Mix.Config

# disable logger
config :logger, level: :warn

# enable ecto sandbox
config :heborn_migration, HEBornMigration.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "heborn_migration_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# comeonim bcrypt rounds
config :comeonin, :bcrypt_log_rounds, 2

# claim route secret
config :heborn_migration,
  claim_secret: "secret"

# config the test mailer
config :heborn_migration, HEBornMigration.TestMailer,
  adapter: Bamboo.TestAdapter

# config helf to use the test mailer
config :helf, HELF.Mailer,
  mailers: [HEBornMigration.TestMailer],
  default_sender: "contact@hackerexperience.com"

# endpoint config
config :heborn_migration, HEBornMigration.Web.Endpoint,
  http: [port: 4001],
  server: false
