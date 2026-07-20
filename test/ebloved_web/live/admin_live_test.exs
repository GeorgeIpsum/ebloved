defmodule EblovedWeb.AdminLiveTest do
  use EblovedWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Ebloved.AccountsFixtures

  test "redirects anonymous users to log in", %{conn: conn} do
    assert {:error, {:redirect, %{to: to}}} = live(conn, ~p"/admin")
    assert to =~ "/users/log"
  end

  test "renders for authenticated user", %{conn: conn} do
    conn = log_in_user(conn, user_fixture())
    {:ok, _view, html} = live(conn, ~p"/admin")
    assert html =~ "Admin"
  end
end
