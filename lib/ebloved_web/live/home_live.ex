defmodule EblovedWeb.HomeLive do
  use EblovedWeb, :live_view

  def mount(_params, _session, socket), do: {:ok, socket}

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl py-16">
      <h1 class="text-3xl font-bold">hello from HEL1</h1>
      <p class="mt-2">A homelab, live.</p>
    </div>
    """
  end
end
