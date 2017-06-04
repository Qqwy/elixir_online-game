defmodule OnlineGame.Web.PageController do
  use OnlineGame.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
