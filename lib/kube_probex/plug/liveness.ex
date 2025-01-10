if {:module, Plug} == Code.ensure_compiled(Plug) do
  defmodule KubeProbex.Plug.Liveness do
    @moduledoc """
    Documentation for `KubeProbex`.
    """

    @behaviour Plug

    @default_path "/healthz"

    alias Plug.Conn

    @impl true
    def init(opts), do: opts

    @impl true
    def call(%Conn{} = conn, opts) do
      if valid_path?(conn, opts) do
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, ~s({"status": "ok"}))
        |> Conn.halt()
      else
        conn
      end
    end

    defp valid_path?(%{request_path: request_path}, opts) do
      opts
      |> Keyword.get(:path, [@default_path])
      |> Enum.member?(request_path)
    end
  end
end
