defmodule HEBornMigration.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(HEBornMigration.Repo, []),
      supervisor(HEBornMigration.Web.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: HEBornMigration.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
