defmodule FifaWeb.PageController do
  use FifaWeb, :controller

  def index(conn, _params) do
    rooms = Fifa.Lobby.get_rooms()
    ps4_status = Fifa.Ps4.get_status()
    render(conn, "index.html", rooms: rooms, ps4_status: ps4_status)
  end
end
