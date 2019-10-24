defmodule Fifa.Ps4 do
  def get_status() do
    data = """
    SRCH * HTTP/1.1
    device-discovery-protocol-version:00020020
    """

    ps4_ip = Application.get_env(:fifa, :ps4_ip)

    server = Socket.UDP.open!
    server |> Socket.Datagram.send(data, {ps4_ip, 987})

    response = server |> Socket.Datagram.recv([timeout: 250])

    case response do
      {:ok, {message, _}} -> parse_message(message)
      {:error, _}         -> %{status_name: "Offline"}
    end
  end

  def get_short_status() do
    status = Fifa.Ps4.get_status()
    parse_status(status)
  end

  def parse_status(status) do
    case status.status_name do
      "Ok"             -> parse_on_status(status)
      "Server Standby" -> "off"
      "Offline"        -> "off"
      _                ->
        IO.inspect status
        "unknown"
    end
  end

  def parse_on_status(status) do
    case status["running-app-name"] do
      nil  -> "on"
      game -> "running #{game}"
    end
  end

  def parse_message(message) do
    lines = message
    |> String.trim
    |> String.split("\n")

    status = hd(lines)

    status_name = status
    |> String.split(" ")
    |> Enum.drop(2)
    |> Enum.join(" ")

    lines
    |> Enum.drop(1)
    |> Enum.map(&String.split(&1, ":"))
    |> List.flatten()
    |> Enum.chunk_every(2)
    |> Map.new(fn [k, v] -> {k, v} end)
    |> Map.put(:status, status)
    |> Map.put(:status_name, status_name)
  end
end
