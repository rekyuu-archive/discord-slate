defmodule DiscordKiso.Commands.General do
  import Din.Module
  import DiscordKiso.Util

  def help(data) do
    reply "https://github.com/rekyuu/discord-kiso/blob/master/README.md"
  end

  def hello(data) do
    replies = ["sup loser", "yo", "ay", "hi", "wassup"]

    if one_to(25) do
      reply Enum.random(replies)
    end
  end

  def same(data) do
    if one_to(25), do: reply "same"
  end

  def ping(data) do
    IO.inspect data
    reply "木曾だ。"
  end
end
