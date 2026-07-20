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

  test "retains a previously fetched value after a later poll fails" do
    Phoenix.PubSub.subscribe(Ebloved.PubSub, "cluster_data")
    {:ok, counter} = Agent.start_link(fn -> 0 end)

    fetch_fun = fn ->
      case Agent.get_and_update(counter, fn n -> {n, n + 1} end) do
        0 -> {:ok, %{cpu_pct: 33.3, mem_pct: 66.6}}
        _ -> {:error, :down}
      end
    end

    start_supervised!({Ebloved.ClusterData, fetch_fun: fetch_fun, interval_ms: 30})

    assert_receive {:cluster_data, %{cpu_pct: 33.3}}, 2_000

    # Give at least one more (failing) poll a chance to run.
    Process.sleep(150)

    assert %{cpu_pct: 33.3, mem_pct: 66.6} = Ebloved.ClusterData.current()
  end
end
