defmodule Fifa.Player do
  @derive Jason.Encoder
  defstruct [:id, :name, is_host: false]
end
