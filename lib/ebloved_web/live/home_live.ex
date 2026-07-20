defmodule EblovedWeb.HomeLive do
  use EblovedWeb, :live_view

  alias Ebloved.ClusterData

  @empty_cluster_data %{cpu_pct: nil, mem_pct: nil, updated_at: nil}

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Ebloved.PubSub, ClusterData.topic())
    end

    {:ok, assign(socket, :cluster_data, current_cluster_data())}
  end

  def handle_info({:cluster_data, data}, socket) do
    {:noreply, assign(socket, :cluster_data, data)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl py-16">
      <h1 class="text-3xl font-bold">hello from HEL1</h1>
      <p class="mt-2">A homelab, live.</p>

      <div class="mt-8 rounded-lg border border-base-300 p-4">
        <h2 class="text-lg font-semibold">Cluster</h2>
        <%= if @cluster_data.updated_at do %>
          <p>CPU: {@cluster_data.cpu_pct}%</p>
          <p>Memory: {@cluster_data.mem_pct}%</p>
          <p class="mt-1 text-sm opacity-70">Updated {@cluster_data.updated_at}</p>
        <% else %>
          <p class="opacity-70">warming up…</p>
        <% end %>
      </div>
    </div>
    """
  end

  defp current_cluster_data do
    if Process.whereis(ClusterData) do
      ClusterData.current()
    else
      @empty_cluster_data
    end
  rescue
    _ -> @empty_cluster_data
  catch
    # GenServer.call/2,3 signals a dead target via exit/1 (e.g.
    # exit({:noproc, ...})), not a raise, so `rescue` alone does not cover
    # the race where ClusterData dies between the whereis/1 check above and
    # the call landing. Catch that exit too so this always degrades to
    # @empty_cluster_data instead of crashing the LiveView process.
    :exit, _ -> @empty_cluster_data
  end
end
