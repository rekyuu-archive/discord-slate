defmodule DiscordKiso.Bot do
  use DiscordKiso.Module
  import DiscordKiso.Util

  # Enforcers
  def admin(msg) do
    guild_id = Nostrum.Api.get_channel!(msg.channel_id)["guild_id"]
    user_id = msg.author.id
    {:ok, member} = Nostrum.Api.get_member(guild_id, user_id)

    db = query_data("guilds", guild_id)

    is_admin = cond do
      db == nil -> true
      db.admin_roles == [] -> true
      true -> Enum.member?(for role <- member["roles"] do
        {role_id, _} = role |> Integer.parse
        Enum.member?(db.admin_roles, role_id)
      end, true)
    end

    cond do
      is_admin -> true
      true -> false
    end
  end

  def rate_limit(msg) do
    command = msg.content |> String.split |> List.first
    {rate, _} = ExRated.check_rate(command, 10_000, 1)

    rate = case admin(msg) do
      true  -> :ok
      false -> rate
    end

    case rate do
      :ok    -> true
      :error -> false
    end
  end

  def nsfw(msg) do
    {:ok, channel} = Nostrum.Api.get_channel(msg.channel_id)
    channel["nsfw"]
  end

  # Event handlers
  handle :MESSAGE_CREATE do
    enforce :rate_limit do
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
    end

    match ["hello", "hi", "hey", "sup"], :hello
    match ["same", "Same", "SAME"], :same

    enforce :admin do
      match ["!ping", "!kiso"], :ping
      match "!setup", :setup
      match "!addrole", :add_role
      match "!delrole", :del_role
      match "!setlog", :set_log_channel
      match "!dellog", :del_log_channel
    end
  end

  handle :PRESENCE_UPDATE do
    guild_id = msg.guild_id |> Integer.to_string
    user_id = msg.user.id
    {:ok, member} = Nostrum.Api.get_member(guild_id, user_id)
    username = member["user"]["username"]

    if msg.game do
      if msg.game.type do
        case msg.game.type do
          0 -> remove_streamer(guild_id, user_id)
          1 ->
            stream_title = msg.game.name
            stream_url = msg.game.url
            twitch_username = msg.game.url |> String.split("/") |> List.last
            log_chan = query_data("guilds", guild_id).log

            stream_list = query_data("streams", guild_id)

            stream_list = case stream_list do
              nil -> []
              streams -> streams
            end

            unless Enum.member?(stream_list, user_id) do
              store_data("streams", guild_id, stream_list ++ [user_id])

              message = case user_id do
                107977662680571904 -> "**#{username}** is now live on Twitch! @here"
                _ -> "**#{username}** is now live on Twitch!"
              end

              twitch_user = "https://api.twitch.tv/kraken/users?login=#{twitch_username}"
              headers = %{"Accept" => "application/vnd.twitchtv.v5+json", "Client-ID" => "#{Application.get_env(:discord_kiso, :twitch_client_id)}"}

              request = HTTPoison.get!(twitch_user, headers)
              response = Poison.Parser.parse!((request.body), keys: :atoms)
              user = response.users |> List.first

              user_channel = "https://api.twitch.tv/kraken/channels/#{user._id}"
              user_info_request = HTTPoison.get!(user_channel, headers)
              user_info_response = Poison.Parser.parse!((user_info_request.body), keys: :atoms)

              game = case user_info_response.game do
                nil -> "streaming on Twitch.tv"
                game -> "playing #{game}"
              end

              reply [content: message, embed: %Nostrum.Struct.Embed{
                color: 0x4b367c,
                title: "#{twitch_username} #{game}",
                url: "#{stream_url}",
                description: "#{stream_title}",
                thumbnail: %Nostrum.Struct.Embed.Thumbnail{url: "#{user.logo}"},
                timestamp: "#{DateTime.utc_now() |> DateTime.to_iso8601()}"
              }], chan: log_chan
            end
        end
      end
    end

    unless msg.game, do: remove_streamer(guild_id, user_id)
  end

  handle _event, do: nil

  # Remove an individual who is not streaming
  def remove_streamer(guild_id, user_id) do
    stream_list = query_data("streams", guild_id)

    stream_list = case stream_list do
      nil -> []
      streams -> streams
    end

    if Enum.member?(stream_list, user_id) do
      store_data("streams", guild_id, stream_list -- [user_id])
    end
  end

  # Rate limited user commands
  def help(msg) do
    reply "temp"
  end

  def avatar(msg) do
    user = msg.mentions |> List.first
    url = "https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar}?size=1024"

    reply [content: "", embed: %Nostrum.Struct.Embed{
      color: 0x00b6b6,
      image: %Nostrum.Struct.Embed.Image{url: url}
    }]
  end

  def pick(msg) do
    [_ | choices] = msg.content |> String.split

    case choices do
      [] -> nil
      choices ->
        choices_list = choices |> Enum.join(" ") |> String.split(", ")
        case length(choices_list) do
          1 -> reply "What? Okay, #{choices_list |> List.first}, I guess. Didn't really give me a choice there."
          _ -> reply "#{choices_list |> Enum.random}"
        end
    end
  end

  def roll(msg) do
    [_ | roll] = msg.content |> String.split

    case roll do
      [] -> reply "#{Enum.random(1..6)}"
      [roll] ->
        [count | amount] = roll |> String.split("d")

        case amount do
          [] ->
            if String.to_integer(count) > 1 do
              reply "#{Enum.random(1..String.to_integer(count))}"
            end
          [amount] ->
            if String.to_integer(count) > 1 do
              rolls = for _ <- 1..String.to_integer(count) do
                "#{Enum.random(1..String.to_integer(amount))}"
              end

              reply rolls |> Enum.join(", ")
            end
        end
    end
  end

  def prediction(msg) do
    predictions = [
      "It is certain.",
      "It is decidedly so.",
      "Without a doubt.",
      "Yes, definitely.",
      "You may rely on it.",
      "As I see it, yes.",
      "Most likely.",
      "Outlook good.",
      "Yes.",
      "Signs point to yes.",
      "Reply hazy, try again.",
      "Ask again later.",
      "Better not tell you now.",
      "Cannot predict now.",
      "Concentrate and ask again.",
      "Don't count on it.",
      "My reply is no.",
      "My sources say no.",
      "Outlook not so good.",
      "Very doubtful."
    ]

    reply Enum.random(predictions)
  end

  def smug(msg) do
    url = "https://api.imgur.com/3/album/zSNC1"
    auth = %{"Authorization" => "Client-ID #{Application.get_env(:discord_kiso, :imgur_client_id)}"}

    request = HTTPoison.get!(url, auth)
    response = Poison.Parser.parse!((request.body), keys: :atoms)
    result = response.data.images |> Enum.random

    reply [content: "", embed: %Nostrum.Struct.Embed{
      color: 0x00b6b6,
      image: %Nostrum.Struct.Embed.Image{url: result.link}
    }]
  end

  def souls_message(msg) do
    url = "http://souls.riichi.me/api"
    request = HTTPoison.get!(url)
    response = Poison.Parser.parse!((request.body), keys: :atoms)

    reply "#{response.message}"
  end

  # Danbooru commands
  def danbooru(msg) do
    {tag1, tag2} = case length(msg.content |> String.split) do
      1 -> {"order:rank", ""}
      2 ->
        [_ | [tag1 | _]] = msg.content |> String.split
        {tag1, ""}
      _ ->
        [_ | [tag1 | [tag2 | _]]] = msg.content |> String.split
        {tag1, tag2}
    end

    reply_danbooru(msg, tag1, tag2)
  end

  def safebooru(msg) do
    {tag1, tag2} = case length(msg.content |> String.split) do
      1 -> {"order:rank", "rating:s"}
      _ ->
        [_ | [tag1 | _]] = msg.content |> String.split
        {tag1, "rating:s"}
    end

    reply_danbooru(msg, tag1, tag2)
  end

  def lewdbooru(msg) do
    {tag1, tag2} = case length(msg.content |> String.split) do
      1 -> {"order:rank", "rating:e"}
      _ ->
        [_ | [tag1 | _]] = msg.content |> String.split
        {tag1, "rating:e"}
    end

    reply_danbooru(msg, tag1, tag2)
  end

  def ecchibooru(msg) do
    {tag1, tag2} = case length(msg.content |> String.split) do
      1 -> {"order:rank", "rating:q"}
      _ ->
        [_ | [tag1 | _]] = msg.content |> String.split
        {tag1, "rating:q"}
    end

    reply_danbooru(msg, tag1, tag2)
  end

  def reply_danbooru(msg, tag1, tag2) do
    case tag1 do
      "help" -> reply "Danbooru is a anime imageboard. You can search up to two tags with this command or you can leave it blank for something random. For details on tags, see <https://danbooru.donmai.us/wiki_pages/43037>.\n\n**Available Danbooru commands**\n`!dan :tag1 :tag2` - default command\n`!safe :tag1` - applies `rating:safe` tag\n`!ecchi :tag1` - applies `rating:questionable` tag\n`!lewd :tag1` - applies `rating:explicit` tag\n\n`!safe` will work anywhere, but the other commands can only be done in NSFW channels."
    _ ->
      case danbooru(tag1, tag2) do
        {post_id, image, result} ->
          character = result.tag_string_character |> String.split
          copyright = result.tag_string_copyright |> String.split

          artist = result.tag_string_artist |> String.split("_") |> Enum.join(" ")
          {char, copy} =
            case {length(character), length(copyright)} do
              {2, _} ->
                first_char =
                  List.first(character)
                  |> String.split("(")
                  |> List.first
                  |> titlecase("_")

                second_char =
                  List.last(character)
                  |> String.split("(")
                  |> List.first
                  |> titlecase("_")

                {"#{first_char} and #{second_char}",
                 List.first(copyright) |> titlecase("_")}
              {1, _} ->
                {List.first(character)
                 |> String.split("(")
                 |> List.first
                 |> titlecase("_"),
                 List.first(copyright) |> titlecase("_")}
              {_, 1} -> {"Multiple", List.first(copyright) |> titlecase("_")}
              {_, _} -> {"Multiple", "Various"}
            end

          extension = image |> String.split(".") |> List.last

          cond do
            Enum.member?(["jpg", "png", "gif"], extension) ->
              reply [content: "", embed: %Nostrum.Struct.Embed{
                color: 0x00b6b6,
                title: "danbooru.donmai.us",
                url: "https://danbooru.donmai.us/posts/#{post_id}",
                description: "#{char} - #{copy}\nDrawn by #{artist}",
                image: %Nostrum.Struct.Embed.Image{url: image}
              }]
            true ->
              thumbnail = "http://danbooru.donmai.us#{result.preview_file_url}"
              reply [content: "", embed: %Nostrum.Struct.Embed{
                color: 0x00b6b6,
                title: "danbooru.donmai.us",
                url: "https://danbooru.donmai.us/posts/#{post_id}",
                description: "#{char} - #{copy}\nDrawn by #{artist}",
                image: %Nostrum.Struct.Embed.Thumbnail{url: thumbnail}
              }]
          end
        message -> reply message
      end
    end
  end

  def nhentai(msg) do
    [_ | tags] = msg.content |> String.split

    case tags do
      [] -> reply "You must search with at least one tag."
      tags ->
        tags = for tag <- tags do
          tag |> URI.encode_www_form
        end |> Enum.join("+")

        request = "https://nhentai.net/api/galleries/search?query=#{tags}&sort=popular" |> HTTPoison.get!
        response = Poison.Parser.parse!((request.body), keys: :atoms)

        try do
          result = response.result |> Enum.shuffle |> Enum.find(fn doujin -> is_dupe?("nhentai", doujin.id) == false end)

          filetype = case List.first(result.images.pages).t do
            "j" -> "jpg"
            "g" -> "gif"
            "p" -> "png"
          end

          artists_tag = result.tags |> Enum.filter(fn(t) -> t.type == "artist" end)
          artists = for tag <- artists_tag, do: tag.name

          artist = case artists do
            [] -> ""
            artists -> "by #{artists |> Enum.sort |> Enum.join(", ")}\n"
          end

          cover = "https://i.nhentai.net/galleries/#{result.media_id}/1.#{filetype}"

          reply [content: "", embed: %Nostrum.Struct.Embed{
                color: 0x00b6b6,
                title: result.title.pretty,
                url: "https://nhentai.net/g/#{result.id}",
                description: "#{artist}",
                image: %Nostrum.Struct.Embed.Image{url: cover}
              }]
      rescue
        KeyError -> reply "Nothing found!"
      end
    end
  end

  # Commands that are not rate limited
  def hello(msg) do
    replies = ["sup loser", "yo", "ay", "hi", "wassup"]

    if one_to(25) do
      reply Enum.random(replies)
    end
  end

  def same(msg) do
    if one_to(25), do: reply "same"
  end

  # Administrative commands
  def ping(msg) do
    IO.inspect msg
    reply "Kuma~!"
  end

  def setup(msg) do
    guild_id = Nostrum.Api.get_channel!(msg.channel_id)["guild_id"]
    db = query_data("guilds", guild_id)

    cond do
      db == nil ->
        store_data("guilds", guild_id, %{admin_roles: []})
        reply "Hiya! Be sure to add an admin role to manage my settings using `!addrole <role>`."
      db.admin_roles == [] -> reply "No admin roles set, anyone can edit my settings! Change this with `!addrole <role>`."
      true -> reply "I'm ready to sortie!"
    end
  end

  def add_role(msg) do
    guild_id = Nostrum.Api.get_channel!(msg.channel_id)["guild_id"]
    db = query_data("guilds", guild_id)
    role_ids = msg.mention_roles

    case role_ids do
      [] -> reply "You didn't specify any roles."
      role_ids ->
        case db.admin_roles do
          [] ->
            db = Map.put(db, :admin_roles, role_ids)
            store_data("guilds", guild_id, db)
            reply "Added roles!"
          admin_roles ->
            db = Map.put(db, :admin_roles, admin_roles ++ role_ids |> Enum.uniq)
            store_data("guilds", guild_id, db)
            reply "Added administrative roles!"
        end
    end
  end

  def del_role(msg) do
    guild_id = Nostrum.Api.get_channel!(msg.channel_id)["guild_id"]
    role_ids = msg.mention_roles
    db = query_data("guilds", guild_id)

    case role_ids do
      [] -> reply "You didn't specify any roles."
      role_ids ->
        case db.admin_roles do
          [] -> reply "There aren't any roles to remove..."
          admin_roles ->
            db = Map.put(db, :admin_roles, admin_roles -- role_ids |> Enum.uniq)
            store_data("guilds", guild_id, db)
            reply "Removed administrative roles."
        end
    end
  end

  def set_log_channel(msg) do
    guild_id = Nostrum.Api.get_channel!(msg.channel_id)["guild_id"]
    db = query_data("guilds", guild_id)

    db = Map.put(db, :log, msg.channel_id)
    store_data("guilds", guild_id, db)
    reply "Okay, I will announce streams here!"
  end

  def del_log_channel(msg) do
    guild_id = Nostrum.Api.get_channel!(msg.channel_id)["guild_id"]
    db = query_data("guilds", guild_id)

    db = Map.put(db, :log, nil)
    store_data("guilds", guild_id, db)
    reply "Okay, I will no longer announce streams."
  end
end