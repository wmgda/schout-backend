defmodule Fifa.Room do
  @derive Jason.Encoder
  defstruct [
    :id,
    :created_at,
    :channel_id,
    note: "",
    game: "FIFA",
    players: [],
    need_players: 4,
    limit: 4
  ]

  def new_room(opts) do
    %Fifa.Room{
      id: UUID.uuid4(),
      created_at: DateTime.utc_now(),
      channel_id: Application.get_env(:fifa, :default_channel_id)
    } |> Map.merge(opts)
  end

  def add_player(room, player_id) do
    players = room.players ++ [player_id]
    %{room | players: players}
  end

  def get_slack_mentions(room) do
    room.players
    |> Enum.map(fn player -> "<@#{player.id}>" end)
    |> Enum.join(" ")
  end

  def get_number_of_players(room) do
    length(room.players) + (room.limit - room.need_players)
  end
end
