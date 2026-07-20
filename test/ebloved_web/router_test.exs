defmodule EblovedWeb.RouterTest do
  use EblovedWeb.ConnCase, async: true

  @moduledoc """
  This is a single-owner app: the owner account is provisioned once,
  out of band, and self-registration must stay permanently closed.
  """

  describe "registration is locked" do
    test "GET /users/register 404s", %{conn: conn} do
      conn = get(conn, "/users/register")
      assert conn.status == 404
    end

    test "POST /users/register 404s", %{conn: conn} do
      conn = post(conn, "/users/register", %{"user" => %{"email" => "new@example.com"}})
      assert conn.status == 404
    end
  end
end
