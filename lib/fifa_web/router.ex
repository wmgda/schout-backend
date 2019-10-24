defmodule FifaWeb.Router do
  use FifaWeb, :router

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

  scope "/slack", FifaWeb do
    pipe_through :api

    post "/interactive", SlackController, :index
    get "/install", SlackController, :install
  end

  scope "/", FifaWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", FifaWeb do
  #   pipe_through :api
  # end
end
