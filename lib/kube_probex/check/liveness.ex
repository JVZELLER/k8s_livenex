defmodule KubeProbex.Check.Liveness do
  @moduledoc """
  Defines the behaviour for implementing HTTP liveness checks.

  This module provides a common contract for handling liveness probe requests
  in a Kubernetes environment. Liveness checks are used by Kubernetes to determine
  if the application is healthy.

  ## Behaviour

  To implement a custom liveness check, a module must implement the `check/2` callback, which:

  - Processes the HTTP request represented by a `Plug.Conn`.
  - Determines and sets the appropriate HTTP response status, headers, and body.

  ## Default Implementation

  By default, the `KubeProbex.Check.Heartbeat` module is used to handle liveness checks.

  ## Custom Readiness Checks

  You can override the default liveness check implementation by configuring your custom module in your application
  under the `:kube_probex` key:

  ```elixir
  config :kube_probex, :readiness_check, MyCustomLivenessCheck
  ```

  Your custom module must implement the `KubeProbex.Check.Liveness` behaviour by defining the `check/2` function.

  ### Example

  A basic custom implementation:

  ```elixir
  defmodule MyCustomLivenessCheck do
    @behaviour KubeProbex.Check.Liveness

    alias Plug.Conn

    @impl true
    def check(conn, _opts) do
      conn
      |> Conn.put_resp_content_type("application/json")
      |> Conn.send_resp(200, ~s({"status": "ok"}))
    end
  end
  ```
  """

  @default_adapter KubeProbex.Check.Heartbeat

  alias Plug.Conn

  @callback check(Conn.t(), keyword) :: Conn.t()

  @doc """
  Executes the liveness check logic.

  This function retrives a custom adapter if its configured
  or uses the default one to processes an HTTP request for a liveness probe.
  It takes a `Plug.Conn` struct and a list of options.

  The implementation determines the response status,
  content type, and body.

  ## Parameters

    - `conn` - The `Plug.Conn` representing the HTTP request.
    - `opts` - A list of options provided for the liveness check plug.
  """
  def check(%Conn{} = conn, opts), do: adapter().check(conn, opts)

  defp adapter do
    Application.get_env(:kube_probex, :liveness_check) || @default_adapter
  end
end
