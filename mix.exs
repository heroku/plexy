defmodule Plexy.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plexy,
      version: "0.1.3",
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      dialyzer: dialyzer()
    ]
  end

  def package do
    [
      description: "Interagent-compatible web services in Elixir, inspired by Pliny",
      licenses: ["MIT"],
      maintainers: [
        "@Adovenmuehle",
        "@blackfist",
        "@joshlewis",
        "@kennyp",
        "@mwoods79",
        "@mathias"
      ],
      links: %{"GitHub" => "https://github.com/heroku/plexy"}
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:plug, "~> 1.0"},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:dialyxir, "~> 0.4", only: [:dev]},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [plt_add_deps: :project]
  end
end
