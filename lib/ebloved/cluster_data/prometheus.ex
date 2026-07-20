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
        {:ok, v |> to_string() |> Float.parse() |> elem(0) |> Float.round(1)}

      other ->
        {:error, other}
    end
  end
end
