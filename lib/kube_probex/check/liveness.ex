defmodule KubeProbex.Check.Liveness do
  @moduledoc """
  Defines the behaviour for implementing HTTP liveness checks.

  This module provides a common contract for handling liveness probe requests
  in a Kubernetes environment.

  ## Default Implementation

  By default, the `Heartbeat` module is used to handle liveness checks. However, you
  can override this behaviour by configuring a custom module in your application
  configuration under the `:kube_probex` key:

  ```elixir
  config :kube_probex, :liveness_check, MyCustomLivenessCheck
  ```
  """

  @default_adapter KubeProbex.Check.Heartbeat

  alias Plug.Conn

  @callback check(Conn.t(), keyword) :: Conn.t()

  @doc """
  Executes the liveness check logic.

  This function processes an HTTP request for a liveness probe. It takes a `Plug.Conn`
  struct and a list of options. The implementation determines the response status,
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
