defmodule KubeProbex.MixProject do
  use Mix.Project

  @name "Kube Probex"
  @source_url "https://github.com/JVZELLER/kube_probex"
  @version "1.0.0"

  def project do
    [
      app: :kube_probex,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [
          :ex_unit,
          :mix,
          :plug
        ],
        list_unused_filters: true,
        # we use the following opt to change the PLT path
        # even though the opt is marked as deprecated, this is the doc-recommended way
        # to do this
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      # Hex
      description:
        "A lightweight Elixir library for defining Kubernetes HTTP probes in Phoenix applications.",
      package: package(),

      # Docs
      name: @name,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Phoenix Plug
      {:plug, "~> 1.16"},

      # Linters, formatters, typespecs, and docs
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},

      # Documentation
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      # To compile module that depends on Ecto
      {:ecto_sql, "~> 3.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["José Victor Zeller"],
      files: ~w(lib .formatter.exs mix.exs README* VERSION CHANGELOG*),
      licenses: ["MIT License"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      source_url: @source_url,
      main: "KubeProbex",
      source_ref: "v#{@version}",
      groups_for_modules: [
        "Available Plugs": [
          KubeProbex.Plug.Liveness,
          KubeProbex.Plug.Readiness
        ],
        Behaviours: [
          KubeProbex.Check.Liveness,
          KubeProbex.Check.Readiness
        ],
        "Default Implementations": [
          KubeProbex.Check.Heartbeat,
          KubeProbex.Check.EctoReady
        ]
      ],
      extra_section: "DOCS",
      extras: ["CHANGELOG.md"]
    ]
  end
end
