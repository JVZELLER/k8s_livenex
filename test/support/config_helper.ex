defmodule KubeProbex.ConfigHelper do
  @moduledoc """
  Helper for dealing with config environment variables
  """

  @doc """
  Changes the config of a specific module and restores it after the test execution.
  """
  @spec toggle_config(app_name :: atom(), config_key :: atom(), value :: any()) :: :ok
  def toggle_config(app, key, value) when is_list(value) do
    previous_config = Application.get_env(app, key) || []
    Application.put_env(app, key, Keyword.merge(previous_config, value))

    ExUnit.Callbacks.on_exit(fn ->
      Application.put_env(app, key, previous_config)
    end)
  end

  def toggle_config(app, key, value) do
    previous_config = Application.get_env(app, key)
    Application.put_env(app, key, value)

    ExUnit.Callbacks.on_exit(fn ->
      Application.put_env(app, key, previous_config)
    end)
  end
end
