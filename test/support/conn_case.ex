defmodule HEBornMigration.Web.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
      import HEBornMigration.Web.Router.Helpers

      @endpoint HEBornMigration.Web.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(HEBornMigration.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(HEBornMigration.Repo, {:shared, self()})
    end
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
