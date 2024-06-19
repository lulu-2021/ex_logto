defmodule ExLogto.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_logto,
      version: "0.1.3",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExLogto.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.2"},
      {:jose, "~> 1.11"},
      {:poison, "~> 6.0.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
      #
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
