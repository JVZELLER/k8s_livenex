defmodule KubeProbex.Check.Heartbeat do
  @moduledoc """
  Provides the default implementation for `KubeProbex.Check.Liveness` behaviour.

  This module provides a basic liveness probe handler that always returns a response with
  the following attributes:

    - **Status**: [`200`](https://http.cat/200)
    - **Content-Type**: `application/json`
    - **Body**: `{"status": "ok"}`

  This indicates that the application is up and running.
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
