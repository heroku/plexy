defmodule Plexy.Mixfile do
  use Mix.Project

  def project do
    [app: :plexy,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:plug, "~> 1.0"}
    ]
  end
end
