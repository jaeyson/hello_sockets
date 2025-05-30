defmodule HelloSockets.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias HelloSockets.Pipeline.Producer
  alias HelloSockets.Pipeline.ConsumerSupervisor, as: Consumer

  @max_demand 10
  @min_demand 5

  @impl true
  def start(_type, _args) do
    :ok = HelloSockets.Statix.connect()

    children = [
      HelloSocketsWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:hello_sockets, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: HelloSockets.PubSub},
      # Start a worker by calling: HelloSockets.Worker.start_link(arg)
      # {HelloSockets.Worker, arg},
      # Start to serve requests, typically the last entry
      {Producer, name: Producer},
      {Consumer, subscribe_to: [{Producer, max_demand: @max_demand, min_demand: @min_demand}]},
      HelloSocketsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloSockets.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HelloSocketsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
