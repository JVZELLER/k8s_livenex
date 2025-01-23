if {:module, Ecto.Migrator} == Code.ensure_compiled(Ecto.Migrator) do
  defmodule KubeProbex.Check.EctoReady do
    @moduledoc """
    Provides the default implementation for Kubernetes readiness probes check using Ecto.

    This module defines a readiness probe handler that ensures database health by performing
    the following checks:

    1. **Pending Migrations**: Checks if there are any pending migrations for the configured repositories.
    2. **Database Storage**: If there are no migrations defined, verifies if the database storage is properly created.

    If any of these checks fail, the module raises appropriate exceptions to indicate the issue:

    - `KubeProbex.Exceptions.Ecto.PendingMigrationsError` is raised if there are pending migrations.
    - `KubeProbex.Exceptions.Ecto.DatabaseNotCreatedError` is raised if the database is not created.

    When all checks pass, the module returns an HTTP response with the following attributes:

    - **Status**: `200 OK`
    - **Content-Type**: `application/json`
    - **Body**: `{"status": "ready"}`

    This indicates that the application is ready to serve traffic.

    This module serves as the default adapter for the `KubeProbex.Check.Readiness` behaviour. It is
    primarily used to ensure that Kubernetes readiness probes respond with a "ready" status only when
    the application database is in a healthy state.

    ## Usage

    This module is used internally by the `KubeProbex` library and should not be called directly.
    Instead, ensure your application specifies the required `:ecto_repos` configuration.

    ### Example

    ```elixir
    config :my_app, :ecto_repos, [MyApp.Repo]
    ```

    ## Options

    - `:otp_apps` - A list of OTP applications whose Ecto repositories should be checked. Each
      application must define its Ecto repositories under the `:ecto_repos` configuration key. This option
      should be passed when setting the plug.

    ### Exemple

    ```elixir
    defmodule MyAppWeb.Router do
      use Phoenix.Endpoint, otp_app: :my_app_web

      plug KubeProbex.Plug.Readiness, path: ~w(/_ready /_readyz), otp_apps: [:my_app_web]
    end
    ````
    """

    @behaviour KubeProbex.Check.Readiness

    alias KubeProbex.Exceptions.Ecto.DatabaseNotCreatedError
    alias KubeProbex.Exceptions.Ecto.PendingMigrationsError

    alias Plug.Conn

    @impl true
    def check(%Conn{} = conn, opts) do
      repos =
        opts
        |> Keyword.get(:otp_apps, [])
        |> List.wrap()
        |> Enum.flat_map(&Application.get_env(&1, :ecto_repos, []))

      for repo <- repos, Process.whereis(repo) do
        check_pending_migrations!(repo, opts) || check_storage_up!(repo)
      end

      conn
      |> Conn.put_resp_content_type("application/json")
      |> Conn.send_resp(200, ~s({"status": "ready"}))
    end

    defp check_storage_up!(repo) do
      adapter = repo.__adapter__()
      repo_config = repo.config()

      repo_config
      |> adapter.storage_status()
      |> case do
        :down ->
          raise DatabaseNotCreatedError, repo: repo

        {:error, reason} ->
          raise "[KubeProbex] Readiness probe failed for repo #{inspect(repo)} due to unexpected reason: #{inspect(reason)}"

        :up ->
          {:ok, :storage_up}
      end
    end

    defp check_pending_migrations!(repo, _opts) do
      migrations = Ecto.Migrator.migrations(repo)
      empty? = Enum.empty?(migrations)

      pending_migrations? =
        Enum.any?(migrations, fn {status, _version, _migration} -> status == :down end)

      cond do
        empty? ->
          nil

        pending_migrations? ->
          raise PendingMigrationsError, repo: repo

        :neither_empty_nor_pending_migrations ->
          {:ok, :all_migrations_up}
      end
    end
  end
end
