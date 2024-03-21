defmodule Geo.Turf.MixProject do
  use Mix.Project

  def project do
    [
      app: :geo_turf,
      version: "0.2.0",
      elixir: "~> 1.15",
      # start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      docs: docs(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp description do
    """
    A spatial analysis tool for Elixir's [Geo](https://github.com/bryanjos/geo) library ported from [TurfJS](http://turfjs.org/).
    """
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
      {:geo, "~> 3.5"},
      {:ex_doc, "~> 0.30", only: :dev},
      {:jason, "~> 1.4", only: [:dev, :test]},
      {:excoveralls, "~> 0.18", only: :test},
      {:fixate, "~> 0.1", only: :test}
    ]
  end

  def docs do
    [
      main: "Geo.Turf"
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "LICENSE"],
      maintainers: ["Jón Grétar Borgþórsson"],
      licenses: ["MIT"],
      source_url: "https://github.com/JonGretar/GeoTurf",
      links: %{"GitHub" => "https://github.com/JonGretar/GeoTurf"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

end
