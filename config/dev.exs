use Mix.Config

# logger config
config :logger, :console, format: "[$level] $message\n"

# repo configs, large timeout cause SMTP latency is high from office
config :heborn_migration, HEBornMigration.Repo,
  database: "heborn_migration_dev",
  pool_size: 4,
  timeout: 60_000,
  pool_timeout: 60_000

# comeonim bcrypt rounds
config :comeonin, :bcrypt_log_rounds, 14

# claim route secret
config :heborn_migration,
  claim_secret: "secret"

# config helf to use the smtp mailer
config :helf, HELF.Mailer,
  mailers: [HEBornMigration.Web.Mailer],
  default_sender: "contact@hackerexperience.com"

# endpoint config
config :heborn_migration, HEBornMigration.Web.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../assets", __DIR__)]]

# livereload config
config :heborn_migration, HEBornMigration.Web.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/heborn_migration/web/views/.*(ex)$},
      ~r{lib/heborn_migration/web/templates/.*(eex)$}
    ]
  ]

# phoenix errors config
config :phoenix, :stacktrace_depth, 20
