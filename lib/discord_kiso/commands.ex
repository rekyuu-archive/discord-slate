defmodule DiscordKiso.Commands do
  defmacro __using__(_opts) do
    quote do
      import DiscordKiso.Commands.{General}
    end
  end
end
