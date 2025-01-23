defmodule Ecto.Migrator do
  @moduledoc false

  @doc false
  def migrations(repo) when repo in [NoMigrationsRepo, StoreageNotCreatedRepo] do
    []
  end

  def migrations(PendingMigrationsRepo) do
    [{:up, "version", "migration"}, {:down, "version", "migration"}]
  end

  def migrations(_repo) do
    [{:up, "version", "migration"}]
  end
end
