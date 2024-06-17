defmodule DontTruckAround.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DontTruckAroundWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:dont_truck_around, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DontTruckAround.PubSub},
      # Start a worker by calling: DontTruckAround.Worker.start_link(arg)
      # {DontTruckAround.Worker, arg},
      # Start to serve requests, typically the last entry
      DontTruckAroundWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DontTruckAround.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DontTruckAroundWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
