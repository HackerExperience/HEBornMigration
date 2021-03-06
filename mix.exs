defmodule HEBornMigration.Mixfile do
  use Mix.Project

  def project do
    [
      app: :heborn_migration,
      version: "0.0.1",
      elixir: "~> 1.4",

      elixirc_options: elixirc_options(Mix.env),
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,

      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      consolidate_protocols: Mix.env == :prod,

      aliases: aliases(),
      deps: deps(),

      dialyzer: [plt_add_apps: [:mix, :phoenix_pubsub]],

      preferred_cli_env: %{
        "test.full": :test,
        "test.unit": :test,
        "test.integration": :test,
        "pr": :test
      },
    ]
  end

  def application do
    [
      mod: {HEBornMigration.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :crypto,
        :bamboo,
        :bamboo_smtp
      ]
    ]
  end

  defp deps do
    [
      {:distillery, "~>1.2", runtime: false},

      {:httpoison, "~> 0.11.2"},

      {:phoenix, "~> 1.3.0-rc"},
      {:cowboy, "~> 1.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},

      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},

      {:helf, github: "HackerExperience/HELF"},
      {:bamboo_smtp, "~> 1.3.0"},
      {:comeonin, "~> 2.5"},
      {:gettext, "~> 0.11"},

      {:burette,
        github: "HackerExperience/burette",
        only: :test},
      {:uuid, "~> 1.1"},
      {:credo, "~> 0.7", only: [:dev, :test]}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["test"],
      "test.full": [
        "ecto.reset",
        "test.unit",
        "test.integration",
        "test.integration"
      ],
      "test.unit": ["test --only unit"],
      "test.integration": ["test --only integration"],
      "pr": [
        "clean",
        "compile",
        "test.full",
        "credo --strict",
        "dialyzer --halt-exit-status"
      ]
    ]
  end

  # Allow warnings on dev, block warnings on tests/production
  defp elixirc_options(:dev) do
    warnings_as_errors? = System.get_env("HELIX_SKIP_WARNINGS") == "false"
    [warnings_as_errors: warnings_as_errors?]
  end
  defp elixirc_options(_) do
    warnings_as_errors? = System.get_env("HELIX_SKIP_WARNINGS") != "true"
    [warnings_as_errors: warnings_as_errors?]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
