defmodule DiscordSlate.Commands.Color do
  import Din.Module
  import DiscordSlate.Util
  alias Din.Resources.{Channel, Guild}
  
  def red, do: "352605883278163989"
  def orange, do: "479314401300578344"
  def yellow, do: "486022292745224203"
  def green, do: "486022159454699540"
  def blue, do: "479314520695767040"
  def purple, do: "352603354259521536"

  def set_color_red(data) do
    guild_id = Channel.get(data.channel_id).guild_id
    user_data = Guild.get_member(guild_id, data.author.id)
    remove_colors = [orange, yellow, green, blue, purple]

    updated_roles = (user_data.roles -- remove_colors) ++ [red]
    Guild.modify_member(guild_id, data.author.id, [roles: updated_roles])

    reply "Done!"
  end

  def set_color_orange(data) do
    guild_id = Channel.get(data.channel_id).guild_id
    user_data = Guild.get_member(guild_id, data.author.id)
    remove_colors = [red, yellow, green, blue, purple]

    updated_roles = (user_data.roles -- remove_colors) ++ [orange]
    Guild.modify_member(guild_id, data.author.id, [roles: updated_roles])

    reply "Done!"
  end

  def set_color_yellow(data) do
    guild_id = Channel.get(data.channel_id).guild_id
    user_data = Guild.get_member(guild_id, data.author.id)
    remove_colors = [red, orange, green, blue, purple]

    updated_roles = (user_data.roles -- remove_colors) ++ [yellow]
    Guild.modify_member(guild_id, data.author.id, [roles: updated_roles])

    reply "Done!"
  end

  def set_color_green(data) do
    guild_id = Channel.get(data.channel_id).guild_id
    user_data = Guild.get_member(guild_id, data.author.id)
    remove_colors = [red, orange, yellow, blue, purple]

    updated_roles = (user_data.roles -- remove_colors) ++ [green]
    Guild.modify_member(guild_id, data.author.id, [roles: updated_roles])

    reply "Done!"
  end

  def set_color_blue(data) do
    guild_id = Channel.get(data.channel_id).guild_id
    user_data = Guild.get_member(guild_id, data.author.id)
    remove_colors = [red, orange, yellow, green, purple]

    updated_roles = (user_data.roles -- remove_colors) ++ [blue]
    Guild.modify_member(guild_id, data.author.id, [roles: updated_roles])

    reply "Done!"
  end

  def set_color_purple(data) do
    guild_id = Channel.get(data.channel_id).guild_id
    user_data = Guild.get_member(guild_id, data.author.id)
    remove_colors = [red, orange, yellow, green, blue]

    updated_roles = (user_data.roles -- remove_colors) ++ [purple]
    Guild.modify_member(guild_id, data.author.id, [roles: updated_roles])

    reply "Done!"
  end

  def set_color_none(data) do
    guild_id = Channel.get(data.channel_id).guild_id
    user_data = Guild.get_member(guild_id, data.author.id)
    remove_colors = [red, orange, yellow, green, blue, purple]

    updated_roles = user_data.roles -- remove_colors
    Guild.modify_member(guild_id, data.author.id, [roles: updated_roles])

    reply "Done!"
  end
end