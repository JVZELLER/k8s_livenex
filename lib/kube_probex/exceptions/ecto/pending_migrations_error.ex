defmodule KubeProbex.Exceptions.Ecto.PendingMigrationsError do
  @moduledoc """
  An exception raised when there are pending database migrations for a specific Ecto repository.

  This exception is used by the `KubeProbex.Check.EctoReady` module during readiness checks
  to indicate that a repository requires migrations to be run before it can be considered ready.
  It provides a clear error message to guide developers in resolving the issue.

  ## Example

  This exception can be triggered if the `Ecto.Repo` has unapplied migrations:

  ```elixir
  raise KubeProbex.Exceptions.Ecto.PendingMigrationsError, repo: MyApp.Repo
  ```

  ## Attributes

  - `repo` - The Ecto repository that has pending migrations.
  """
  defexception [:repo]

  @impl Exception
  def message(%__MODULE__{repo: repo}) do
    "[KubeProbex] there are pending migrations for repo: #{inspect(repo)}. " <>
      "Try running `mix ecto.migrate` in the command line to migrate it"
  end
end
