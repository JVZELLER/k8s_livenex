defmodule KubeProbex.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a HTTP connection.

  Such tests rely on `Plug.Test` and also import other
  functionality to make it easier to build test plugs.
  """

  use ExUnit.CaseTemplate

  alias Plug.Conn

  using do
    quote do
      # Import conveniences for testing with connections
      use Plug.Test

      import KubeProbex.ConnCase

      alias KubeProbex.ConfigHelper
    end
  end

  def assert_status(%{status: status} = conn, expected_status) do
    assert status == expected_status

    conn
  end

  def assert_response(%{resp_body: body} = conn, expected_body) do
    assert body == expected_body

    conn
  end

  def assert_resp_header(conn, header, expected) do
    [resp_headers] = Conn.get_resp_header(conn, header)

    assert resp_headers =~ expected

    conn
  end
end
