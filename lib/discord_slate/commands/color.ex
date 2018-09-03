defmodule DiscordSlate.Commands.Color do
  import Din.Module
  import DiscordSlate.Util
  alias Din.Resources.{Channel, Guild}

  ["352605883278163989", "479314520695767040"]

  def color_to_id(text) do
    case String.downcase(text) do
      "red"    -> 352605883278163989
      "orange" -> 479314401300578344
      "yellow" -> 486022292745224203
      "green"  -> 486022159454699540
      "blue"   -> 479314520695767040
      "purple" -> 352603354259521536
    end
  end

  def set_color_red(data) do
    guild_id = Channel.get(data.channel_id).guild_id
    user_data = Guild.get_member(guild_id, data.author.id)
    remove_colors = ["479314401300578344", "486022292745224203", "486022159454699540", "479314520695767040", "352603354259521536"]

    updated_roles = user_data.roles -- remove_colors ++ [352605883278163989]
    Guild.modify_member(guild_id, data.author.id, updated_roles)

    reply "Done!"
  end

  def set_color_orange(data) do
    guild_id = Channel.get(data.channel_id).guild_id

    Guild.remove_member_role(guild_id, data.author.id, 352605883278163989)
    Guild.remove_member_role(guild_id, data.author.id, 486022292745224203)
    Guild.remove_member_role(guild_id, data.author.id, 486022159454699540)
    Guild.remove_member_role(guild_id, data.author.id, 479314520695767040)
    Guild.remove_member_role(guild_id, data.author.id, 352603354259521536)
    
    Guild.add_member_role(guild_id, data.author.id, 479314401300578344)

    reply "Done!"
  end

  def set_color_yellow(data) do
    guild_id = Channel.get(data.channel_id).guild_id

    Guild.remove_member_role(guild_id, data.author.id, 352605883278163989)
    Guild.remove_member_role(guild_id, data.author.id, 479314401300578344)
    Guild.remove_member_role(guild_id, data.author.id, 486022159454699540)
    Guild.remove_member_role(guild_id, data.author.id, 479314520695767040)
    Guild.remove_member_role(guild_id, data.author.id, 352603354259521536)
    
    Guild.add_member_role(guild_id, data.author.id, 486022292745224203)

    reply "Done!"
  end

  def set_color_green(data) do
    guild_id = Channel.get(data.channel_id).guild_id

    Guild.remove_member_role(guild_id, data.author.id, 352605883278163989)
    Guild.remove_member_role(guild_id, data.author.id, 479314401300578344)
    Guild.remove_member_role(guild_id, data.author.id, 486022292745224203)
    Guild.remove_member_role(guild_id, data.author.id, 479314520695767040)
    Guild.remove_member_role(guild_id, data.author.id, 352603354259521536)
    
    Guild.add_member_role(guild_id, data.author.id, 486022159454699540)

    reply "Done!"
  end

  def set_color_blue(data) do
    guild_id = Channel.get(data.channel_id).guild_id

    Guild.remove_member_role(guild_id, data.author.id, 352605883278163989)
    Guild.remove_member_role(guild_id, data.author.id, 479314401300578344)
    Guild.remove_member_role(guild_id, data.author.id, 486022292745224203)
    Guild.remove_member_role(guild_id, data.author.id, 486022159454699540)
    Guild.remove_member_role(guild_id, data.author.id, 352603354259521536)
    
    Guild.add_member_role(guild_id, data.author.id, 479314520695767040)

    reply "Done!"
  end

  def set_color_purple(data) do
    guild_id = Channel.get(data.channel_id).guild_id

    Guild.remove_member_role(guild_id, data.author.id, 352605883278163989)
    Guild.remove_member_role(guild_id, data.author.id, 479314401300578344)
    Guild.remove_member_role(guild_id, data.author.id, 486022292745224203)
    Guild.remove_member_role(guild_id, data.author.id, 486022159454699540)
    Guild.remove_member_role(guild_id, data.author.id, 479314520695767040)

    Guild.add_member_role(guild_id, data.author.id, 352603354259521536)

    reply "Done!"
  end

  def set_color_none(data) do
    guild_id = Channel.get(data.channel_id).guild_id

    Guild.remove_member_role(guild_id, data.author.id, 352605883278163989)
    Guild.remove_member_role(guild_id, data.author.id, 479314401300578344)
    Guild.remove_member_role(guild_id, data.author.id, 486022292745224203)
    Guild.remove_member_role(guild_id, data.author.id, 486022159454699540)
    Guild.remove_member_role(guild_id, data.author.id, 479314520695767040)
    Guild.remove_member_role(guild_id, data.author.id, 352603354259521536)

    reply "Done!"
  end
end