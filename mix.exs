defmodule ExLogto.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_logto,
      version: "0.1.4",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
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
      {:jason, "~> 1.4.4"},
      {:jose, "~> 1.11"},
      #{:poison, "~> 6.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
      #
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description do
    """
    Elixir client for https://logto.io
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Netflakes"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lulu-2021/ex_logto"}
    ]
  end
end
