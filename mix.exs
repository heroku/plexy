defmodule Plexy.Mixfile do
  use Mix.Project

  @source_url "https://github.com/heroku/plexy"
  @version "0.3.3"

  def project do
    [
      app: :plexy,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
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
      links: %{"GitHub" => @source_url}
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:elixir_uuid, "~> 1.2"},
      {:plug, "~> 1.0"},
      {:credo, "~> 1.7", only: [:dev, :test]},
      {:dialyxir, "~> 0.4", only: [:dev]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "#{@version}",
      formatters: ["html"]
    ]
  end

  defp dialyzer do
    [plt_add_deps: :project]
  end
end
