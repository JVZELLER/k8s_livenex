defmodule KubeProbex.Plug.LivenessTest do
  use ExUnit.Case
  use Plug.Test

  alias KubeProbex.Plug.Liveness

  @default_path "/healthz"

  describe "init/1" do
    test "returns the given opts" do
      opts = expected = [hello: :workd]
      assert Liveness.init(opts) == expected
    end
  end

  describe "call/2" do
    @opts Liveness.init([])
    test "it returns 200 to liveness path using default path" do
      :get
      |> conn(@default_path)
      |> put_req_header("accept", "application/json")
      |> Liveness.call(@opts)
      |> assert_status()
      |> assert_response()
    end

    test "should ignore non liveness requests" do
      conn =
        :get
        |> conn("/api/v1/users")
        |> put_req_header("accept", "application/json")
        |> Liveness.call(@opts)

      refute conn.resp_body
      refute conn.status
    end

    @opts Liveness.init(path: ["/_health", "/_test"])
    test "it accepts a list of path on options" do
      for path <- @opts[:path] do
        :get
        |> conn(path)
        |> put_req_header("accept", "application/json")
        |> Liveness.call(@opts)
        |> assert_status()
        |> assert_response()
      end
    end
  end

  defp assert_status(%{status: status} = conn), do: assert(status == 200) && conn

  defp assert_response(%{resp_body: body} = conn),
    do: assert(body == ~s({"status": "ok"})) && conn
end
