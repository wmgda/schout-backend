defmodule FifaWeb.SlackController do
  use FifaWeb, :controller

  def index(conn, params) do
    payload = params["payload"] |> Poison.decode!
    user = payload["user"]

    action = hd(payload["actions"])
    room_id = action["value"]

    player = %Fifa.Player{id: user["id"], name: user["username"]}

    {:ok, :player_added, room} = Fifa.Lobby.add_player(room_id, player)

    blocks = FifaSlack.Blocks.build_room_blocks(room)
    body = %{blocks: blocks} |> Poison.encode!

    payload["response_url"]
    |> HTTPoison.post!(body)

    json(conn, %{status: "OK"})
  end

  def install(conn, params) do

  end
end
