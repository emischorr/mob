defmodule MobWeb.Router do
  use MobWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MobWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/group", PageController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", MobWeb do
  #   pipe_through :api
  # end
end
