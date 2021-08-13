defmodule ElexusHub.MixProject do
  use Mix.Project

  def project do
    [
      app: :elexus_hub,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "Elexus Hub",
      source_url: "https://github.com/bdanklin/elexus_hub",
      homepage_url: "https://github.com/bdanklin/elexus_hub",
      docs: [
        # The main page in the docs
        main: "ElexusHub",
        logo: "./logo.png",
        extras: ["README.md"]
      ],
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:httpoison, "~> 1.7"},
      {:jason, "~> 1.0"},
      {:morphix, "~> 0.8.0"}
    ]
  end

  defp description() do
    "A lightweight wrapper for the ElexusHub Hub API written in Elixir."
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bdanklin/ElexusHub"}
    ]
  end
end
