defmodule MyApp.CustomReadinessCheck do
  @behaviour KubeProbex.Check.Readiness

  alias Plug.Conn

  @response ~s({"status": "ready", "custom": "check"})

  @impl true
  def check(conn, _opts) do
    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(200, @response)
  end

  def response, do: @response
end

defmodule KubeProbex.Plug.ReadinessTest do
  use KubeProbex.ConnCase, async: false

  alias KubeProbex.Plug.Readiness

  @default_path "/readyz"
  @default_response ~s({"status": "ready"})

  describe "init/1" do
    test "returns the given opts" do
      opts = expected = [hello: :workd]
      assert Readiness.init(opts) == expected
    end
  end

  describe "call/2" do
    @opts Readiness.init(otp_apps: [:my_app])
    test "it returns 200 to Readiness path using default path" do
      :get
      |> conn(@default_path)
      |> put_req_header("accept", "application/json")
      |> Readiness.call(@opts)
      |> assert_status(200)
      |> assert_response(@default_response)
      |> assert_resp_header("content-type", "application/json")
    end

    test "should ignore non Readiness requests" do
      conn =
        :get
        |> conn("/api/v1/users")
        |> put_req_header("accept", "application/json")
        |> Readiness.call(@opts)

      refute conn.resp_body
      refute conn.status
    end

    @opts Readiness.init(path: ["/_health", "/_test"], otp_apps: [:my_app])
    test "it accepts a list of path on options" do
      for path <- @opts[:path] do
        :get
        |> conn(path)
        |> put_req_header("accept", "application/json")
        |> Readiness.call(@opts)
        |> assert_status(200)
        |> assert_response(@default_response)
        |> assert_resp_header("content-type", "application/json")
      end
    end

    @opts Readiness.init([])
    test "it uses a custom check implementation" do
      ConfigHelper.toggle_config(:kube_probex, :readiness_check, MyApp.CustomReadinessCheck)

      custom_response = MyApp.CustomReadinessCheck.response()

      :get
      |> conn(@default_path)
      |> put_req_header("accept", "application/json")
      |> Readiness.call(@opts)
      |> assert_status(200)
      |> assert_response(custom_response)
      |> assert_resp_header("content-type", "application/json")
    end
  end
end
