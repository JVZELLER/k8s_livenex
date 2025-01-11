if {:module, Plug} == Code.ensure_compiled(Plug) do
  defmodule KubeProbex.Plug.Liveness do
    @moduledoc """
    Documentation for `KubeProbex`.
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
