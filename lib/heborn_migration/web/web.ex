defmodule HEBornMigration.Web do
  def controller do
    quote do
      use Phoenix.Controller, namespace: HEBornMigration.Web
      import Plug.Conn
      import HEBornMigration.Web.Router.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/heborn_migration/web/templates",
                        namespace: HEBornMigration.Web

      import Phoenix.Controller,
        only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      use Phoenix.HTML

      import HEBornMigration.Web.Router.Helpers
      import HEBornMigration.Web.ErrorHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
