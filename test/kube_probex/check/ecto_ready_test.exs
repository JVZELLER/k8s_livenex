repos = [DummyRepo, DummyRepo2, NoMigrationsRepo, PendingMigrationsRepo, StoreageNotCreatedRepo]

for repo <- repos do
  defmodule repo do
    use GenServer

    def start_link(_opts) do
      GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
    end

    @impl true
    def init(init_arg) do
      {:ok, init_arg}
    end

    def __adapter__, do: Ecto.DummyAdapter

    def config do
      if __MODULE__ == StoreageNotCreatedRepo, do: [status: :down], else: []
    end
  end
end

defmodule KubeProbex.Check.EctoReadyTest do
  # Although each test modifies the configuration,
  # the changes are isolated and do not affect others,
  # making it safe to set `async: true`.
  use KubeProbex.ConnCase, async: true

  alias KubeProbex.Check.EctoReady
  alias KubeProbex.Exceptions.Ecto.DatabaseNotCreatedError
  alias KubeProbex.Exceptions.Ecto.PendingMigrationsError

  setup_all do
    Application.put_env(:my_app, :ecto_repos, [DummyRepo, NoMigrationsRepo])
    Application.put_env(:my_app_not_started, :ecto_repos, [NotStarted])
    Application.put_env(:my_second_app, :ecto_repos, [DummyRepo2])
    Application.put_env(:my_app_storage_down, :ecto_repos, [StoreageNotCreatedRepo])
    Application.put_env(:my_app_pending_migrations, :ecto_repos, [PendingMigrationsRepo])

    Application.put_env(:my_app_mixed, :ecto_repos, [
      DummyRepo,
      NotStarted,
      NoMigrationsRepo,
      StoreageNotCreatedRepo,
      PendingMigrationsRepo
    ])

    for repo <- unquote(repos) do
      {:ok, _pid} = ExUnit.Callbacks.start_supervised(repo)
    end

    :ok
  end

  describe "check/2" do
    test "returns a 200 ready response with JSON content type and body when apps are ready" do
      for apps <- [[:my_app], [:my_app, :my_second_app]] do
        :get
        |> conn("/some/path")
        |> put_req_header("accept", "application/json")
        |> EctoReady.check(otp_apps: apps)
        |> assert_status(200)
        |> assert_response(~s({"status": "ready"}))
        |> assert_resp_header("content-type", "application/json")
      end
    end

    test "returns a 200 ready response with JSON type and body when no repo is configured" do
      :get
      |> conn("/some/path")
      |> put_req_header("accept", "application/json")
      |> EctoReady.check(otp_apps: [:app_with_no_repo])
      |> assert_status(200)
      |> assert_response(~s({"status": "ready"}))
      |> assert_resp_header("content-type", "application/json")
    end

    test "returns a 200 ready response with JSON type and body when repo is configured, but no started" do
      :get
      |> conn("/some/path")
      |> put_req_header("accept", "application/json")
      |> EctoReady.check(otp_apps: [:my_app_not_started])
      |> assert_status(200)
      |> assert_response(~s({"status": "ready"}))
      |> assert_resp_header("content-type", "application/json")
    end

    test "raises DatabaseNotCreatedError when storage status is :down" do
      assert_raise DatabaseNotCreatedError, fn ->
        :get
        |> conn("/some/path")
        |> put_req_header("accept", "application/json")
        |> EctoReady.check(otp_apps: [:my_app_storage_down])
      end
    end

    test "raises PendingMigrationsError when there are pending migrations" do
      assert_raise PendingMigrationsError, fn ->
        :get
        |> conn("/some/path")
        |> put_req_header("accept", "application/json")
        |> EctoReady.check(otp_apps: [:my_app_pending_migrations])
      end
    end

    test "handles multiple repos with one down, one pending migrations, and the the others ready" do
      # Since StorageNotCreatedRepo is listed before PendingMigrationsRepo,
      # a storage error should be raised instead of a pending migrations error.
      assert_raise DatabaseNotCreatedError, fn ->
        :get
        |> conn("/some/path")
        |> put_req_header("accept", "application/json")
        |> EctoReady.check(otp_apps: [:my_app_mixed])
      end
    end
  end
end
