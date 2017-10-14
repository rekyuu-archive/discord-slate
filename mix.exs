defmodule DiscordKiso.Mixfile do
  use Mix.Project

  def project do
    [app: :discord_kiso,
     version: "0.2.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:ex_rated, :din, :logger, :httpoison],
     mod: {DiscordKiso, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:din, git: "https://github.com/rekyuu/Din"},
     {:ex_rated, "~> 1.2"}]
  end
end
