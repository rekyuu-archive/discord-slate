defmodule DiscordSlate.Commands.Color do
  import Din.Module
  import DiscordSlate.Util
  alias Din.Resources.{Channel, Guild}

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
    Guild.add_member_role(guild_id, data.author.id, 352605883278163989)

    reply "Done!"
  end

  def set_color_orange(data) do
    guild_id = Channel.get(data.channel_id).guild_id    
    Guild.add_member_role(guild_id, data.author.id, 479314401300578344)

    reply "Done!"
  end

  def set_color_yellow(data) do
    guild_id = Channel.get(data.channel_id).guild_id    
    Guild.add_member_role(guild_id, data.author.id, 486022292745224203)

    reply "Done!"
  end

  def set_color_green(data) do
    guild_id = Channel.get(data.channel_id).guild_id    
    Guild.add_member_role(guild_id, data.author.id, 486022159454699540)

    reply "Done!"
  end

  def set_color_blue(data) do
    guild_id = Channel.get(data.channel_id).guild_id    
    Guild.add_member_role(guild_id, data.author.id, 479314520695767040)

    reply "Done!"
  end

  def set_color_purple(data) do
    guild_id = Channel.get(data.channel_id).guild_id    
    Guild.add_member_role(guild_id, data.author.id, 352603354259521536)

    reply "Done!"
  end
end