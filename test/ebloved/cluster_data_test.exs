defmodule Ebloved.ClusterDataTest do
  use ExUnit.Case, async: false

  test "broadcasts and caches fetched metrics" do
    Phoenix.PubSub.subscribe(Ebloved.PubSub, "cluster_data")

    start_supervised!(
      {Ebloved.ClusterData,
       fetch_fun: fn -> {:ok, %{cpu_pct: 12.5, mem_pct: 40.0}} end, interval_ms: 60_000}
    )

    assert_receive {:cluster_data, %{cpu_pct: 12.5, mem_pct: 40.0}}, 2_000
    assert %{cpu_pct: 12.5} = Ebloved.ClusterData.current()
  end

  test "keeps last-known-good on fetch failure" do
    start_supervised!(
      {Ebloved.ClusterData, fetch_fun: fn -> {:error, :down} end, interval_ms: 60_000}
    )

    Process.sleep(100)
    assert %{cpu_pct: nil} = Ebloved.ClusterData.current()
  end
end
