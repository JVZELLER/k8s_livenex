# K8S Livenex

`k8s_livenex` is a lightweight and flexible Elixir library designed to help define liveness probes in Kubernetes for applications built using the Phoenix framework. It leverages Phoenix Plug to integrate seamlessly into your web application, making it easy to ensure that your services remain healthy and responsive in Kubernetes environments.

## Features
- **Simple Integration**: Add liveness probes to your Phoenix app with minimal configuration.
- **Customizable Checks**: Define your own liveness logic to suit your application's needs.
- **Kubernetes-Ready**: Built with Kubernetes liveness probe endpoints in mind.
- **Lightweight**: Minimal dependencies and easy to use.

## Installation

Add `k8s_livenex` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:k8s_livenex, "~> 0.1.0"}
  ]
end
```

Then, fetch the dependencies:

```bash
mix deps.get
```

## Usage

### Adding the Plug to Your Phoenix Router

To use `k8s_livenex`, add it to your Phoenix router as a plug:

```elixir
# lib/my_app_web/router.ex

defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/health" do
    pipe_through :api

    # Add the liveness route
    forward "/liveness", K8sLivenex.Plug
  end
end
```

This will expose a liveness probe endpoint at `/health/liveness`.

### Customizing Liveness Checks

You can define custom liveness checks by configuring `k8s_livenex`. Add a module implementing the `K8sLivenex.Check` behaviour:

```elixir
defmodule MyApp.LivenessCheck do
  @behaviour K8sLivenex.Check

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

Then, configure `k8s_livenex` to use your custom check in `config/config.exs`:

```elixir
config :k8s_livenex,
  liveness_check: MyApp.LivenessCheck
```

### Kubernetes Configuration

In your Kubernetes deployment manifest, configure the liveness probe to point to the exposed endpoint:

```yaml
livenessProbe:
  httpGet:
    path: /health/liveness
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

`k8s_livenex` is released under the [MIT License](LICENSE).

---

Start defining your Kubernetes liveness probes easily and effectively with `k8s_livenex`!
