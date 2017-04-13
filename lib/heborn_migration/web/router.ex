defmodule HEBornMigration.Web.Router do
  use HEBornMigration.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HEBornMigration.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/claim/:display_name", PageController, :claim
  end

  # Other scopes may use custom stacks.
  # scope "/api", HEBornMigration.Web do
  #   pipe_through :api
  # end
end
