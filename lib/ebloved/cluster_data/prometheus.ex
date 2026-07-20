defmodule Ebloved.ClusterData.Prometheus do
  @moduledoc "Instant-query fetcher for node CPU/mem percentages."

  def fetch do
    base = Application.fetch_env!(:ebloved, :prometheus_url)

    with {:ok, cpu} <-
           query(base, ~s|100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[2m])))|),
         {:ok, mem} <-
           query(
             base,
             ~s|100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)|
           ) do
      {:ok, %{cpu_pct: cpu, mem_pct: mem}}
    end
  end

  defp query(base, promql) do
    case Req.get(base <> "/api/v1/query",
           params: [query: promql],
           retry: false,
           receive_timeout: 3_000
         ) do
      {:ok, %{status: 200, body: %{"data" => %{"result" => [%{"value" => [_ts, v]} | _]}}}} ->
        parse_value(v)

      other ->
        {:error, other}
    end
  end

  @doc false
  # Public (but undocumented) so it can be unit-tested directly: Prometheus
  # instant queries can return HTTP 200 with a non-numeric value (notably
  # "NaN", which `rate()` over a short/empty window commonly returns).
  # `Float.parse/1` returns `:error` for those, so this degrades to
  # `{:error, _}` instead of raising and crashing the ClusterData GenServer.
  def parse_value(v) do
    case Float.parse(to_string(v)) do
      {f, _} -> {:ok, Float.round(f, 1)}
      :error -> {:error, {:unparseable, v}}
    end
  end
end
