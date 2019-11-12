defmodule FifaSlack.Controller do
  use Slack
  import Slack.Web.Chat
  require Logger

  def handle_connect(slack, state) do
    Logger.info "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_close(reason, _slack, _state) do
    Logger.info "Disconnected, reason: #{reason}"
    :close
  end

  def create_room(message, slack, note \\ "") do
    channel = slack.channels[message.channel]

    game = case channel[:name] do
      "pilkarzyki"   -> "Piłkarzyki"
      "rocketleague" -> "Rocket League"
      _              -> "FIFA"
    end

    player = %Fifa.Player{
      id: message.user,
      name: slack.users[message.user].real_name,
      is_host: true
    }
    room = Fifa.Room.new_room(%{
      note: note,
      game: game,
      players: [player],
      channel_id: message.channel
    })
    Fifa.Lobby.add_room(room)
  end

  def check_status(message, _slack) do
    short_status = Fifa.Ps4.get_short_status()
    post_message(message.channel, "PS4 is #{short_status}")
  end

  def handle_event(_message = %{type: "message", bot_id: _}, _, state), do: {:ok, state}
  def handle_event(message = %{type: "message", text: text}, slack, state) do
    Logger.info "Received message: #{text}"

    text = text |> String.trim |> String.downcase

    case text do
      "gramy" <> note -> create_room(message, slack, note)
      "start" <> note -> create_room(message, slack, note)
      "status"        -> check_status(message, slack)
      _               -> nil
    end

    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}
  # def handle_event(message, _, state) do
  #   IO.inspect message

  #   {:ok, state}
  # end

  def handle_info({:message, text, channel}, slack, state) do
    Logger.info "Sending your message, captain!"

    send_message(text, channel, slack)

    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}

  # def handle_info(message, _, state) do
  #   IO.inspect message

  #   {:ok, state}
  # end

end
