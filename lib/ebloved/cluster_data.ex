defmodule Ebloved.ClusterData do
  @moduledoc "Polls cluster metric sources, caches last-known-good, broadcasts on PubSub."
  use GenServer

  @topic "cluster_data"
  @empty %{cpu_pct: nil, mem_pct: nil, updated_at: nil}

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  def current, do: GenServer.call(__MODULE__, :current)
  def topic, do: @topic

  @impl true
  def init(opts) do
    state = %{
      data: @empty,
      fetch_fun: Keyword.get(opts, :fetch_fun, &Ebloved.ClusterData.Prometheus.fetch/0),
      interval:
        Keyword.get(opts, :interval_ms, Application.get_env(:ebloved, :poll_interval_ms, 5_000))
    }

    send(self(), :poll)
    {:ok, state}
  end

  @impl true
  def handle_call(:current, _from, state), do: {:reply, state.data, state}

  @impl true
  def handle_info(:poll, state) do
    state =
      case state.fetch_fun.() do
        {:ok, metrics} ->
          data = Map.put(metrics, :updated_at, DateTime.utc_now())
          Phoenix.PubSub.broadcast(Ebloved.PubSub, @topic, {:cluster_data, data})
          %{state | data: data}

        {:error, _} ->
          state
      end

    Process.send_after(self(), :poll, state.interval)
    {:noreply, state}
  end
end
