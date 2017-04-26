use Mix.Config

# logger config
config :logger, level: :info

# repo configs
config :heborn_migration, HEBornMigration.Repo,
  pool_size: 20,  database: "heborn_migration_prod",
  timeout: 30_000,
  pool_timeout: 30_000

# comeonim bcrypt rounds
config :comeonin, :bcrypt_log_rounds, 14

# config helf to use the smtp mailer
config :helf, HELF.Mailer,
  mailers: [HEBornMigration.Web.Mailer],
  default_sender: "contact@hackerexperience.com"

# claim route secret
config :heborn_migration,
  claim_secret: System.get_env("HEBORN_MIGRATION_CLAIM_SECRET")

# endpoint config
config :heborn_migration, HEBornMigration.Web.Endpoint,
  code_reloader: false,
  http: [port: 4000]

