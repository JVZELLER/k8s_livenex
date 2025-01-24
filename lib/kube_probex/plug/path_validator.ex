defmodule KubeProbex.Plug.PathValidator do
  @moduledoc """
  A helper module for validating HTTP paths of incoming Kubernetes probe requests.

  It provides functionality to check if an HTTP request matches the expected path
  for a Kubernetes probe (e.g., liveness, readiness).

  > #### **Note** {: .warning}
  >
  > This is an internal module and is not intended for direct use.
  """

  alias Plug.Conn

  @doc """
  Validates if the request's path matches the expected path for a Kubernetes probe.

  This function checks the `request_path` of an incoming `Plug.Conn` against a list
  of allowed paths. If a custom path is provided in the `plug_opts` argument, it will use
  that for validation. Otherwise, it falls back to the `default_path`.

  ## Parameters

    - `conn` - The `%Plug.Conn{}` struct representing the incoming request.
    - `plug_opts` - A keyword list of options passed to the probe plug, which may contain
      a `:path` key specifying custom paths.
    - `default_path` - A string representing the default probe path to validate against.

  ## Example

  Assuming the default path:
  ```elixir
    iex> conn = %Plug.Conn{request_path: "/health/liveness"}
    iex> opts = []
    iex> KubeProbex.Plug.PathValidator.valid_path?(conn, opts, "/health/liveness")
    true
  ```

  With a customized path:
  ```elixir
    iex> conn = %Plug.Conn{request_path: "/custom/liveness"}
    iex> opts = [path: ["/custom/liveness"]]
    iex> KubeProbex.Plug.PathValidator.valid_path?(conn, opts, "/health/liveness")
    true
  ```
  """
  @spec valid_path?(Conn.t(), keyword(), String.t()) :: boolean()
  def valid_path?(%Conn{request_path: request_path}, plug_opts, default_path) do
    plug_opts
    |> Keyword.get(:path, [default_path])
    |> Enum.member?(request_path)
  end
end
