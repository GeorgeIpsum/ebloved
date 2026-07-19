defmodule EblovedWeb.HomeLiveTest do
  use EblovedWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "renders landing page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "hello from HEL1"
  end
end
