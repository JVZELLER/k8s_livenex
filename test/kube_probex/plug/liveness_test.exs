defmodule MyApp.CustomLivenessCheck do
  @behaviour KubeProbex.Check.Liveness

  alias Plug.Conn

  @response ~s({"status": "ok", "custom": "check"})

  @impl true
  def check(conn, _opts) do
    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(200, @response)
  end

  def response, do: @response
end

defmodule KubeProbex.Plug.LivenessTest do
  use KubeProbex.ConnCase, async: false

  alias KubeProbex.Plug.Liveness

  @default_path "/healthz"
  @default_response ~s({"status": "ok"})

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
      |> assert_status(200)
      |> assert_response(@default_response)
      |> assert_resp_header("content-type", "application/json")
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
        |> assert_status(200)
        |> assert_response(@default_response)
        |> assert_resp_header("content-type", "application/json")
      end
    end

    @opts Liveness.init([])
    test "it uses a custom check implementation" do
      ConfigHelper.toggle_config(:kube_probex, :liveness_check, MyApp.CustomLivenessCheck)

      custom_response = MyApp.CustomLivenessCheck.response()

      :get
      |> conn(@default_path)
      |> put_req_header("accept", "application/json")
      |> Liveness.call(@opts)
      |> assert_status(200)
      |> assert_response(custom_response)
      |> assert_resp_header("content-type", "application/json")
    end
  end
end
