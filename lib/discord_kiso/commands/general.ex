defmodule DiscordKiso.Commands.General do
  import DiscordKiso.{Module, Util}

  def help(msg) do
    reply "I'm Kiso. I'll bestow upon you the absolute best victory.\n\n**Initial setup**\nType `!setup` to add your server to my database. From there you should set tell me what roles can edit my settings by using `!addrole :role`.\n\n**Stream Alerts**\nI will always announce everyone in the server when they go live. Just set which channel to announce to by going to that channel and typing `!setlog`.\n\nTo see a full list of commands, see <https://github.com/rekyuu/discord-kiso>."
  end

  def hello(msg) do
    replies = ["sup loser", "yo", "ay", "hi", "wassup"]

    if one_to(25) do
      reply Enum.random(replies)
    end
  end

  def same(msg) do
    if one_to(25), do: reply "same"
  end

  def ping(msg) do
    IO.inspect msg
    reply "木曾だ。"
  end
end
