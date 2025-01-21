if {:module, Plug} == Code.ensure_compiled(Plug) do
  defmodule KubeProbex.Plug.Liveness do
    @moduledoc """
    A plug for handling Kubernetes HTTP liveness probe requests.

    This module integrates with Phoenix or Plug applications to define a liveness probe
    endpoint. It validates the incoming request's path and executes the configured liveness
    check logic.

    ## Default Behavior

    - The default path for liveness probes is `"/healthz"`.
    - The liveness check is performed using the `KubeProbex.Check.Liveness` behaviour.
    - If the incoming request's path does not match the expected path, the request is passed
      through unaltered.

    ## Configuration

    You can customize the path for the liveness probe by providing a `:path` option
    when configuring this plug. If no custom path is provided, the default path `"/healthz"`
    will be used.

    ## Example

    Add the liveness plug to your router or endpoint to define the liveness probe:

      ```elixir
      defmodule MyAppWeb.Router do
        use Phoenix.Endpoint, otp_app: :my_app_web

        plug KubeProbex.Plug.Liveness, path: ~w(/_health /_healthz)
      end
      ```
    """

    @behaviour Plug

    @default_path "/healthz"

    alias KubeProbex.Check.Liveness
    alias KubeProbex.Plug.PathValidator
    alias Plug.Conn

    @impl true
    def init(opts), do: opts

    @impl true
    def call(%Conn{} = conn, opts) do
      if PathValidator.valid_path?(conn, opts, @default_path) do
        conn
        |> Liveness.check(opts)
        |> Conn.halt()
      else
        conn
      end
    end
  end
end
