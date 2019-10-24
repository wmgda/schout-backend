defmodule FifaWeb.LobbyChannel do
  use Phoenix.Channel

  def join("lobby", _message, socket) do
    {:ok, socket}
  end

  def handle_in("create_room", body, socket) do
    room = Fifa.Room.new_room(%{
      game: body["game"],
      need_players: body["need_players"],
      limit: body["limit"]
    })
    Fifa.Lobby.add_room(room)
    {:reply, {:ok, room}, socket}
  end

  def handle_in("get_ps4_status", _, socket) do
    status = Fifa.Ps4.get_short_status()
    status = %{status: status}

    broadcast(socket, "ps4_status_changed", status)

    {:reply, {:ok, status}, socket}
  end

  def handle_in("get_rooms", _, socket) do
    rooms = Fifa.Lobby.get_rooms()
    {:reply, {:ok, rooms}, socket}
  end

  def handle_in("ping", _, socket) do
    {:reply, :pong, socket}
  end
end
