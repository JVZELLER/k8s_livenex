defmodule KubeProbex.Check.HeartbeatTest do
  use KubeProbex.ConnCase

  alias KubeProbex.Check.Heartbeat

  describe "check/2" do
    test "returns a 200 OK response with JSON content type and body" do
      :get
      |> conn("/some/path")
      |> put_req_header("accept", "application/json")
      |> Heartbeat.check([])
      |> assert_status(200)
      |> assert_response(~s({"status": "ok"}))
      |> assert_resp_header("content-type", "application/json")
    end
  end
end
