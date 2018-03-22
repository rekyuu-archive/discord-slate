defmodule DiscordSlate.Bot do
  use Din.Module
  alias Din.Resources.{Channel, Guild}

  use DiscordSlate.Commands
  import DiscordSlate.Util

  handle :message_create do
    enforce :admin do
      match "!ping", :ping
      match "!setup", :setup
      match "!adminrole add", :add_role
      match "!adminrole del", :del_role
      match "!announce here", :set_log_channel
      match "!announce stop", :del_log_channel
      match "!announce test", :test_announce
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
            Enum.member?(db.admin_roles, role)
          end, true)
        end
    end
  end
end
