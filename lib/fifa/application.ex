defmodule Fifa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      FifaWeb.Endpoint,
      Fifa.Lobby,
      Fifa.Ps4Monitor
      # Starts a worker by calling: Fifa.Worker.start_link(arg)
      # {Fifa.Worker, arg},
    ]

    token = Application.get_env(:slack, :bot_token)
    Slack.Bot.start_link(FifaSlack.Controller, [], token)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fifa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FifaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
