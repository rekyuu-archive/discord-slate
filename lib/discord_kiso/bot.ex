defmodule DiscordKiso.Bot do
  use Din.Module
  alias Din.Resources.{Channel, Guild}

  use DiscordKiso.Commands
  import DiscordKiso.Util

  handle :message_create do
    match "!help", :help
    match "!avatar", :avatar
    match ["!coin", "!flip"], do: reply Enum.random(["Heads.", "Tails."])
    match ["!pick", "!choose"], :pick
    match "!roll", :roll
    match "!predict", :prediction
    match "!smug", :smug
    match "!guidance", :souls_message
    match "!safe", :safebooru

    enforce :nsfw do
      match "!dan", :danbooru
      match "!ecchi", :ecchibooru
      match "!lewd", :lewdbooru
      match ["!nhen", "!nhentai", "!doujin"], :nhentai
    end

    match ["hello", "hi", "hey", "sup"], :hello
    match ["same", "Same", "SAME"], :same

    enforce :admin do
      match ["!ping", "!kiso"], :ping
      match "!setup", :setup
      match "!adminrole add", :add_role
      match "!adminrole del", :del_role
      match "!announce here", :set_log_channel
      match "!announce stop", :del_log_channel
      match ["!alertfor user add", "!alertfor role add"], :alert_add_individual_users_or_roles
      match ["!alertfor user delete", "!alertfor user del", "!alertfor user remove", "!alertfor user rem", "!alertfor role delete", "!alertfor role del", "!alertfor role remove", "!alertfor role rem"], :alert_remove_individual_users_or_roles
      match "!at role", :set_mention_role
      match "!at here", :del_mention_role
      match "!announce role", :set_stream_announce
      match "!announce everyone", :del_stream_announce
      match ["!command add", "!command set", "!command edit"], :add_custom_command
      match ["!command del", "!command delete", "!command remove", "!command rem"], :del_custom_command

      custom_command(data)
    end
  end

  handle :presence_update, do: announce(data)

  handle :guild_delete, do: remove_from_guild(data)

  handle_fallback()

  defp admin(data) do
    guild_id = Channel.get(data.channel_id).guild_id

    case guild_id do
      nil -> false
      guild_id ->
        user_id = data.author.id
        member = Guild.get_member(guild_id, user_id)

        db = query_data("guilds", guild_id)

        cond do
          db == nil -> true
          db.admin_roles == [] -> true
          true -> Enum.member?(for role <- member.roles do
            Enum.member?(db.admin_roles, role_id)
          end, true)
        end
    end
  end

  defp nsfw(data) do
    channel = Channel.get(data.channel_id)

    case channel.nsfw do
      nil -> true
      nsfw -> nsfw
    end
  end
end
