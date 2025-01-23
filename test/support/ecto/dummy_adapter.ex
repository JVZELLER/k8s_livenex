defmodule Ecto.DummyAdapter do
  @moduledoc false

  @doc false
  def storage_status(config), do: config[:status] || :up
end
