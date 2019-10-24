defmodule Fifa.Ps4Monitor do
  use Task
  import FifaWeb.Endpoint
  import Slack.Web.Chat

  def start_link(_arg) do
    Task.start_link(&poll/0)
  end

  def poll(last_status \\ "") do
    receive do
    after
      10_000 ->
        new_status = check_status(last_status)
        poll(new_status)
    end
  end

  defp check_status(last_status) do
    status = Fifa.Ps4.get_short_status()

    if (last_status != "" && last_status != status) do
      broadcast("lobby", "ps4_status_changed", %{status: status})

      channel_id = Application.get_env(:fifa, :default_channel_id)
      post_message(channel_id, "PS4 is now #{status}.")
    end

    status
  end
end
