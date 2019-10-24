defmodule Fifa.Lobby do
  use Agent

  import FifaWeb.Endpoint
  import Slack.Web.Chat

  def start_link(_) do
    Agent.start_link(fn -> Map.new() end, name: __MODULE__)
  end

  def add_room(room) do
    Agent.update(__MODULE__, &Map.put(&1, room.id, room))

    IO.puts "room #{room.id} created"

    blocks = FifaSlack.Blocks.build_room_blocks(room) |> Poison.encode!()
    post_message(room.channel_id, "", %{blocks: blocks})

    broadcast("lobby", "room_created", room)

    {:ok, :room_created, room}
  end

  def add_player(room_id, player) do
    rooms = Agent.get_and_update(__MODULE__, fn rooms ->
      room = Map.get(rooms, room_id)|> Fifa.Room.add_player(player)
      rooms = Map.put(rooms, room.id, room)

      {rooms, rooms}
    end)

    room = rooms |> Map.get(room_id)

    IO.puts "player #{player.id} joined room #{room.id}"

    broadcast("lobby", "player_joined", room)
    broadcast("room:#{room.id}", "player_joined", %{player: player, room: room})

    if (length(room.players) >= room.need_players) do
      mentions = Fifa.Room.get_slack_mentions(room)
      ps4_status = Fifa.Ps4.get_short_status()

      post_message(room.channel_id, "#{mentions} let's play #{room.game}! PS4 is now #{ps4_status}.")
    end

    {:ok, :player_added, room}
  end

  def get_room(id) do
    Agent.get(__MODULE__, &Map.get(&1, id))
  end

  def get_rooms() do
    Agent.get(__MODULE__, fn rooms -> rooms end)
  end
end
