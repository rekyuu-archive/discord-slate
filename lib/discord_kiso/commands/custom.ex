defmodule DiscordKiso.Commands.Custom do
  import DiscordKiso.{Module, Util}

  def add_custom_command(msg) do
    [_ | [command | action]] = msg.content |> String.split
    action = action |> Enum.join(" ")
    guild_id = Nostrum.Api.get_channel!(msg.channel_id)["guild_id"]

    exists = query_data(:commands, "#{guild_id}_!#{command}")
    store_data(:commands, "#{guild_id}_!#{command}", action)

    case exists do
      nil -> reply "Alright! Type !#{command} to use."
      _   -> reply "Done, command !#{command} updated."
    end
  end

  def del_custom_command(msg) do
    [_ | [command | _]] = msg.content |> String.split
    guild_id = Nostrum.Api.get_channel!(msg.channel_id)["guild_id"]
    action = query_data(:commands, "#{guild_id}_!#{command}")

    case action do
      nil -> reply "Command does not exist."
      _   ->
        delete_data(:commands, "#{guild_id}_!#{command}")
        reply "Command !#{command} removed."
    end
  end

  def custom_command(msg) do
    command = msg.content |> String.split |> List.first
    guild_id = Nostrum.Api.get_channel!(msg.channel_id)["guild_id"]
    action = query_data(:commands, "#{guild_id}_#{command}")

    case action do
      nil -> nil
      action -> reply action
    end
  end
end
