# Kube Probex

`kube_probex` is a lightweight and flexible Elixir library designed to help define HTTP probes in Kubernetes for applications built using the Phoenix framework. It leverages Phoenix Plug to integrate seamlessly into your web application, making it easy to ensure that your services remain healthy and responsive in Kubernetes environments.

## Features

- **Simple Integration**: Add liveness, readiness, and startup probes to your Phoenix app with minimal configuration.
- **Customizable Checks**: Define your own liveness, readiness, and startup probes logic to suit your application's needs.
- **Kubernetes-Ready**: Built with Kubernetes probe endpoints in mind.
- **Lightweight**: Minimal dependencies and easy to use.

## Installation

Add `kube_probex` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kube_probex, "~> 0.1.0"}
  ]
end
```

Then, fetch the dependencies:

```bash
mix deps.get
```

## Getting started

To use `kube_probex`, add it to your Phoenix endpoint or router as a plug:

```elixir
# lib/my_app_web/endpoint.ex

defmodule MyAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_app_web

  plug KubeProbex.Plug.Liveness, path: ~w(/_health /_healthz)
  plug KubeProbex.Plug.Readiness, path: ~w(/_ready /_readyz), otp_apps: [:my_app]
end
```

This will expose:
- A liveness probe endpoint at `/_health` and `/_healthz` paths.
- A readiness probe endpoint at `/_ready` and `/_readyz` paths.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request with improvements or bug fixes.

### Running Tests

To run tests locally:

```bash
mix test
```

## License

`kube_probex` is released under the MIT License.

---

Start defining your Kubernetes liveness probes easily and effectively with `kube_probex`!
