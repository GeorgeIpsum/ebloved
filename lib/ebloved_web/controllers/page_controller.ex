defmodule EblovedWeb.PageController do
  use EblovedWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
