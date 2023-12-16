defmodule TodoLive.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TodoLiveWeb.Telemetry,
      TodoLive.Repo,
      {DNSCluster, query: Application.get_env(:todo_live, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TodoLive.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TodoLive.Finch},
      # Start a worker by calling: TodoLive.Worker.start_link(arg)
      # {TodoLive.Worker, arg},
      # Start to serve requests, typically the last entry
      TodoLiveWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TodoLive.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TodoLiveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
