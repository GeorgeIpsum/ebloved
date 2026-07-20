defmodule Ebloved.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        EblovedWeb.Telemetry,
        Ebloved.Repo,
        {DNSCluster, query: Application.get_env(:ebloved, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Ebloved.PubSub}
      ] ++
        poller_children() ++
        [
          # Start to serve requests, typically the last entry
          EblovedWeb.Endpoint
        ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ebloved.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EblovedWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp poller_children do
    if Application.get_env(:ebloved, :start_poller) == false do
      []
    else
      [Ebloved.ClusterData]
    end
  end
end
