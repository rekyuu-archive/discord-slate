defmodule DiscordKiso.Commands.General do
  import DiscordKiso.Util
  require DiscordKiso.Module

  def help(msg) do
    reply "I'm Kiso. I'll bestow upon you the absolute best victory.\n\n**Initial setup**\nType `!setup` to add your server to my database. From there you should set tell me what roles can edit my settings by using `!addrole :role`.\n\n**Stream Alerts**\nI will always announce everyone in the server when they go live. Just set which channel to announce to by going to that channel and typing `!setlog`.\n\nTo see a full list of commands, see <https://github.com/rekyuu/discord-kiso>."
  end
end
