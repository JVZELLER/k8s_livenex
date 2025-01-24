if {:module, Plug} == Code.ensure_compiled(Plug) do
  defmodule KubeProbex.Plug.Readiness do
    @moduledoc """
    A plug for handling Kubernetes HTTP readiness probe requests.

    This module integrates with Phoenix applications to define a readiness probe
    endpoint. It validates the incoming request's path and executes the configured readiness
    check logic.

    ## Default Behavior

    - The default path for readiness probes is `"/readyz"`.
    - The readiness check is performed using the `KubeProbex.Check.Readiness` behaviour implemented
      by `KubeProbex.Check.EctoReady` by default. Check its documentation for more details on how to use it.
    - If the incoming request's path does not match the expected path, the request is passed
      through unaltered.

    ## Configuration

    You can customize the path for the readiness probe by providing a `:path` option
    when configuring this plug. If no custom path is provided, the default path `"/readyz"`
    will be used.

    ## Example

    Add the readiness plug to your router or endpoint to define the readiness probe:

    ```elixir
    defmodule MyAppWeb.Router do
      use Phoenix.Endpoint, otp_app: :my_app_web

      plug KubeProbex.Plug.Readiness, path: ~w(/_ready /_readyz), otp_apps: [:my_app_web]
    end
    ```
    """

    @behaviour Plug

    @default_path "/readyz"

    alias KubeProbex.Check.Readiness
    alias KubeProbex.Plug.PathValidator
    alias Plug.Conn

    @impl true
    def init(opts), do: opts

    @impl true
    def call(%Conn{} = conn, opts) do
      if PathValidator.valid_path?(conn, opts, @default_path) do
        conn
        |> Readiness.check(opts)
        |> Conn.halt()
      else
        conn
      end
    end
  end
end
