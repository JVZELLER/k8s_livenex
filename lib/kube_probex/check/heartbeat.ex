defmodule KubeProbex.Check.Heartbeat do
  @moduledoc """
  The default implementation for the Kubernetes liveness probe check.

  This module provides a basic liveness probe handler that always responds with a status
  of [`200`](https://http.cat/200) and a simple JSON payload: `{"status": "ok"}`.

  It serves as the default adapter for the `KubeProbex.Check.Liveness` behaviour.
  """

  @behaviour KubeProbex.Check.Liveness

  alias Plug.Conn

  @impl true
  def check(%Conn{} = conn, _opts) do
    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(200, ~s({"status": "ok"}))
  end
end
