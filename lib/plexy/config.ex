defmodule Plexy.Config do
  @moduledoc """
  Provides access to a hard coded config value, a value stored as a environment
  variable on the current system at runtime or a default provided value.

  The config.exs can look like this
  ```
  config :plexy,
    redis_url: {:system, "REDIS_URL"},
    port: {:system, "PORT", 5000},
    normal: "normal"
  ```

  When using this modules `get/3` function, System.get_env("REDIS_URL") will be
  ran at runtime.
  """

  defmacro __using__(opts \\ [name: :plexy]) do
    unless opts[:name] do
      raise "Option `:name` missing from configuration"
    end

    quote do
      def get(key, default \\ nil) do
        Plexy.Config.get(unquote(opts[:name]), key, default)
      end

      def get_int(key, default \\ nil) do
        Plexy.Config.get_int(unquote(opts[:name]), key, default)
      end

      def get_bool(key, default \\ nil) do
        Plexy.Config.get_bool(unquote(opts[:name]), key, default)
      end
    end
  end

  @doc """
  Used to gain access to the application env.
    ## Examples

       iex> Application.put_env(:my_config, HerokuApi, heroku_api_url: "https://api.heroku.com")
       iex> Plexy.Config.get(:my_config, [HerokuApi, :heroku_api_url])
       "https://api.heroku.com"
       iex> Plexy.Config.get(:my_config, [HerokuApi, :not_set], "and a default")
       "and a default"

       iex> Application.put_env(:my_config, :redis_url, "redis://localhost:6379")
       iex> Plexy.Config.get(:my_config, :redis_url)
       "redis://localhost:6379"
       iex> Plexy.Config.get(:my_config, :foo, "and a default")
       "and a default"
  """
  @spec get(atom(), atom() | [atom(), ...], any()) :: any()
  def get(config_name, key, default \\ nil)

  def get(config_name, [key | keys], default) do
    default_resolver = fn
      nil ->
        default

      found ->
        found
    end

    config_name
    |> Application.get_env(key)
    |> get_in(keys)
    |> default_resolver.()
    |> resolve(default)
  end

  def get(config_name, key, default) do
    config_name
    |> Application.get_env(key, default)
    |> resolve(default)
  end

  @doc """
  Like `get/3` except it attempts to convert the value to an integer.
    ## Examples
       iex> Application.put_env(:my_config, :port, "5000")
       iex> Plexy.Config.get_int(:my_config, :port, 9999)
       5000
       iex> Plexy.Config.get_int(:my_config, :foo, "123")
       123
  """
  def get_int(config_name, key, default \\ nil) do
    case get(config_name, key, default) do
      value when is_integer(value) ->
        value

      value when is_binary(value) ->
        String.to_integer(value)

      _error ->
        raise "Attempted to parse a value #{key} that could not be converted to an integer"
    end
  end

  @doc """
  Like `get/3` except it attempts to convert the value to an bool.
    ## Examples
       iex> Plexy.Config.get_bool(:my_config, :bar, "true")
       true
       iex> Plexy.Config.get_bool(:my_config, :bar, "yes")
       true
       iex> Plexy.Config.get_bool(:my_config, :foo, "0")
       false
       iex> Plexy.Config.get_bool(:my_config, :baz, "no")
       false
       iex> Plexy.Config.get_bool(:my_config, :baz, "false")
       false
       iex> Plexy.Config.get_bool(:my_config, :baz, nil)
       false
  """
  def get_bool(config_name, key, default \\ nil) do
    case get(config_name, key, default) do
      value when value in [false, "false", "f", 0, "0", "no", "n", nil] ->
        false

      _value ->
        true
    end
  end

  @doc false
  defp resolve({:system, var_name, config_default}, _default) do
    System.get_env(var_name) || config_default
  end

  defp resolve({:system, var_name}, default) do
    System.get_env(var_name) || default
  end

  defp resolve(value, _default) do
    value
  end
end
