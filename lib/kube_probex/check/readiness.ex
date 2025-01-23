defmodule KubeProbex.Check.Readiness do
  @moduledoc """
  Defines the behaviour for implementing Kubernetes HTTP readiness checks.

  This module specifies a contract for handling readiness probe requests in a Kubernetes environment.
  Readiness checks are used by Kubernetes to determine if the application is ready to serve traffic.

  ## Behaviour

  To implement a custom readiness check, a module must define the `check/2` callback, which:

  - Processes the HTTP request represented by a `Plug.Conn`.
  - Determines and sets the appropriate HTTP response status, headers, and body.

  ## Default Implementation

  By default, the `KubeProbex.Check.EctoReady` module is used to handle readiness checks.

  ## Custom Readiness Checks

  You can override the default readiness check implementation by configuring your custom module in your application
  under the `:kube_probex` key:

  ```elixir
  config :kube_probex, :readiness_check, MyCustomReadinessCheck
  ```

  Your custom module must implement the `KubeProbex.Check.Readiness` behaviour by defining the `check/2` function.

  ### Example

  A basic custom implementation:

  ```elixir
  defmodule MyCustomReadinessCheck do
    @behaviour KubeProbex.Check.Readiness

    alias Plug.Conn

    @impl true
    def check(conn, _opts) do
      conn
      |> Conn.put_resp_content_type("application/json")
      |> Conn.send_resp(200, ~s({"status": "ready"}))
    end
  end
  ```
  """

  @default_adapter KubeProbex.Check.EctoReady

  alias Plug.Conn

  @callback check(Conn.t(), keyword) :: Conn.t()

  @doc """
  Executes the readiness check logic.

  This function processes an HTTP request for a readiness probe. It takes a `Plug.Conn`
  struct and a list of options. The implementation determines the response status,
  content type, and body.

  ## Parameters

    - `conn` - The `Plug.Conn` representing the HTTP request.
    - `opts` - A list of options provided for the readiness check plug.
  """
  def check(%Conn{} = conn, opts), do: adapter().check(conn, opts)

  defp adapter do
    Application.get_env(:kube_probex, :readiness_check) || @default_adapter
  end
end
