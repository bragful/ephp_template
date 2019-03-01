defmodule EphpTemplate.MixProject do
  use Mix.Project

  def project do
    [
      app: :ephp_template,
      name: "Ephp Template",
      description: "PHP Template for Phoenix Framework",
      package: package(),
      version: "0.1.0",
      elixir: "~> 1.7",
      source_url: "https://github.com/bragful/ephp_template",
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
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "mix.lock", "README*", "COPYING*"],
      maintainers: ["Manuel Rubio"],
      licenses: ["LGPL 2.1"],
      links: %{
        "GitHub" => "https://github.com/bragful/ephp_template",
        "Bragful" => "https://bragful.com",
      },
    ]
  end
end
