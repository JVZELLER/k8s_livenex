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

## Usage

### Adding the Plug to Your Phoenix Router

To use `kube_probex`, add it to your Phoenix router as a plug:

```elixir
# lib/my_app_web/endpoint.ex

defmodule MyAppWeb.Router do
  use Phoenix.Endpoint, otp_app: :my_app_web

  plug KubeProbex.Plug.Liveness, path: ~w(/_health /_healthz)
end
```

This will expose a liveness probe endpoint at `/_health` and `/_healthz` paths.

### Customizing Probe Checks

You can define custom probe checks by configuring `kube_probex`. Add a module implementing the `KubeProbex.Check` behaviour:

```elixir
defmodule MyApp.LivenessCheck do
  @behaviour KubeProbex.Check

  @impl true
  def check do
    # Return `:ok` if healthy, `{:error, reason}` otherwise
    if some_condition() do
      :ok
    else
      {:error, "Some condition failed"}
    end
  end

  defp some_condition do
    # Your custom logic here
    true
  end
end
```

Then, configure `kube_probex` to use your custom check in `config/config.exs`:

```elixir
config :kube_probex,
  liveness_check: MyApp.LivenessCheck
```

### Kubernetes Configuration

In your Kubernetes deployment manifest, configure the liveness probe to point to the exposed endpoint:

```yaml
livenessProbe:
  httpGet:
    path: /_health
    port: 4000
  initialDelaySeconds: 5
  periodSeconds: 10
```

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request with improvements or bug fixes.

### Running Tests

To run tests locally:

```bash
mix test
```

## License

`kube_probex` is released under the [MIT License](LICENSE).

---

Start defining your Kubernetes liveness probes easily and effectively with `kube_probex`!
