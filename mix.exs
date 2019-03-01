defmodule EphpTemplate.MixProject do
  use Mix.Project

  def project do
    [
      app: :ephp_template,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {EphpTemplate.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_html, "~> 2.10"},
      {:ephp, "~> 0.2"},
    ]
  end
end
