defmodule KubeProbex.Exceptions.Ecto.DatabaseNotCreatedError do
  @moduledoc """
  An exception raised when a database storage is not created for a specific Ecto repository.

  This exception is used by the `KubeProbex.Check.EctoReady` module during readiness checks
  to signal that the required database storage has not been initialized. It provides
  a clear error message to guide developers in resolving the issue.

  ## Attributes

  - `repo` - The Ecto repository for which the database storage is missing.
  """

  defexception [:repo]

  @impl Exception
  def message(%__MODULE__{repo: repo}) do
    "[KubeProbex] the storage is not created for repo: #{inspect(repo)}. " <>
      "Try running `mix ecto.create` in the command line to create it"
  end
end
