defmodule EblovedWeb.HealthController do
  use EblovedWeb, :controller
  def show(conn, _params), do: json(conn, %{status: "ok"})
end
