defmodule EblovedWeb.HomeLiveTest do
  use EblovedWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "renders landing page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "hello from HEL1"
  end

  test "updates the cluster data widget on broadcast", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    send(
      view.pid,
      {:cluster_data, %{cpu_pct: 55.0, mem_pct: 20.0, updated_at: DateTime.utc_now()}}
    )

    assert render(view) =~ "55.0"
  end
end
