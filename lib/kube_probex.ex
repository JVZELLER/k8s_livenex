defmodule KubeProbex do
  @moduledoc """
  Kube Probex is a lightweight and flexible Elixir library designed to help define HTTP probes in Kubernetes
  for applications built using the Phoenix framework. It leverages Phoenix Plug to integrate seamlessly into your
  web application, making it easy to ensure that your services remain healthy and responsive in Kubernetes environments.

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

  ### Adding the Plugs to Your Phoenix Endpoint or Router

  To use `kube_probex`, add it to your Phoenix endpoint or router as a plug:

  <!-- tabs-open -->

  ### Liveness

  ```elixir
  # lib/my_app_web/endpoint.ex

  defmodule MyAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_app_web

  plug KubeProbex.Plug.Liveness, path: ~w(/_health /_healthz)
  end
  ```

  This will expose:
    - A liveness probe endpoint at `/_health` and `/_healthz` paths.

  ### Readiness

  ```elixir
  # lib/my_app_web/endpoint.ex

  defmodule MyAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_app_web

  plug KubeProbex.Plug.Readiness, path: ~w(/_ready /_readyz), otp_apps: [:my_app]
  end
  ```

  This will expose:
    - A readiness probe endpoint at `/_ready` and `/_readyz` paths.

  <!-- tabs-close -->

  > #### Note {: .tip}
  >
  > Check the **Available Plugs** section in the sidebar for a list of all available plugs.

  ### Customizing Probe Checks

  You can define custom probe checks by configuring `kube_probex`. Add a module implementing one of the
  check behaviours:

  ```elixir
  defmodule MyApp.LivenessCheck do
    @behaviour KubeProbex.Check.Liveness

    alias Plug.Conn

    @impl true
    def check(conn, _liveness_plug_opts) do
      if some_condition() do
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, ~s({"status": "ok"}))
      else
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(500, ~s({"status": "error"}))
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
  config :kube_probex, liveness_check: MyApp.LivenessCheck
  ```

  #### Kubernetes Configuration

  In your Kubernetes deployment manifest, configure the liveness probe to point to the exposed endpoint:

  ```yaml
  livenessProbe:
  httpGet:
    path: /_health
    port: 4000
  initialDelaySeconds: 5
  periodSeconds: 10
  ```

  > #### Note {: .tip}
  >
  > Check the **Behaviours** section in the sidebar for a list of all behaviours.
  """
end
