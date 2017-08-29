defmodule DiscordKiso.Bot do
  use DiscordKiso.{Module, Commands}
  import DiscordKiso.Util

  handle :MESSAGE_CREATE do
    match "!help", :help
    match "!avatar", :avatar
    match ["!coin", "!flip"], do: reply Enum.random(["Heads.", "Tails."])
    match ["!pick", "!choose"], :pick
    match "!roll", :roll
    match "!predict", :prediction
    match "!smug", :smug
    match "!guidance", :souls_message
    match "!safe", :safebooru
    match_all :custom_command

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
      match "!addrole", :add_role
      match "!delrole", :del_role
      match "!setlog", :set_log_channel
      match "!stoplog", :del_log_channel
      match "!addhere", :add_log_user
      match "!delhere", :del_log_user
      match "!setmention", :set_mention_role
      match "!stopmention", :del_mention_role
      match "!streamrole", :set_stream_announce
      match "!streamany", :del_stream_announce
      match ["!add", "!set"], :add_custom_command
      match "!del", :del_custom_command
    end
  end

  handle :PRESENCE_UPDATE, do: announce(msg)

  def handle_event(_, state), do: {:ok, state}

  defp admin(msg) do
    guild_id = Nostrum.Api.get_channel!(msg.channel_id)["guild_id"]
    user_id = msg.author.id
    {:ok, member} = Nostrum.Api.get_member(guild_id, user_id)

    db = query_data("guilds", guild_id)

    cond do
      db == nil -> true
      db.admin_roles == [] -> true
      true -> Enum.member?(for role <- member["roles"] do
        {role_id, _} = role |> Integer.parse
        Enum.member?(db.admin_roles, role_id)
      end, true)
    end
  end

  defp nsfw(msg) do
    {:ok, channel} = Nostrum.Api.get_channel(msg.channel_id)
    channel["nsfw"]
  end
end
