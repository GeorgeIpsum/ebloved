defmodule EblovedWeb.HealthControllerTest do
  use EblovedWeb.ConnCase, async: true

  test "GET /healthz returns ok", %{conn: conn} do
    conn = get(conn, ~p"/healthz")
    assert json_response(conn, 200) == %{"status" => "ok"}
  end
end
