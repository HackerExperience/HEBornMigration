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
    pipe_through :browser

    get "/", PageController, :get_migrate
    post "/", PageController, :post_migrate

    get "/confirm", PageController, :get_confirm
    post "/confirm", PageController, :post_confirm

    get "/claim/:secret/:username", PageController, :claim_by_link
    get "/confirm/:code", PageController, :confirm_by_link
  end
end
