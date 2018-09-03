defmodule DiscordSlate.Commands do
  defmacro __using__(_opts) do
    quote do
      import DiscordSlate.Commands.{Admin, Announce, Color}
    end
  end
end
