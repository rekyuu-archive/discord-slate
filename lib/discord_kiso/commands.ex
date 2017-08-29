defmodule DiscordKiso.Commands do
  defmacro __using__(_opts) do
    quote do
      import DiscordKiso.Commands.{
        Admin,
        Announce,
        Custom,
        General,
        Image,
        Random
      }
    end
  end
end
