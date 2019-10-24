defmodule FifaSlack.Blocks do
  import Fifa.Room

  def build_room_blocks(room) do
    need = room.limit - get_number_of_players(room)
    slots = "#{get_number_of_players(room)}/#{room.limit}"

    description = [room.game, room.note, slots]
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.join(" | ")

    description = "We are looking for #{need} more people to play #{room.game} | #{slots}"

    blocks = [
      %{
        type: "section",
        text: %{
          type: "mrkdwn",
          text: description
        }
      }
    ]

    other_players = room.players |> Enum.filter(fn player -> !player.is_host end)
    blocks = blocks ++ Enum.map(other_players, fn player -> %{
			type: "context",
			elements: [
				%{
					type: "mrkdwn",
					text: "<@#{player.id}> has joined"
				}
			]
		} end)

    if room.need_players > length(room.players) do
      blocks ++ [
        %{
          type: "actions",
          block_id:  "123",
          elements: [
            %{
              type: "button",
              text: %{type: "plain_text", text: "Join!"},
              style: "primary",
              value: room.id
            }
          ]
        }
      ]
    else
      blocks
    end
  end
end
