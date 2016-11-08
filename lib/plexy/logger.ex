defmodule Plexy.Logger do
  @moduledoc """
  Plexy.Logger is a proxy to Elixir's built-in logger that knows how to
  handle non char-data and has a few other helpful logging functions.
  """

  require Logger


  @doc """
  Logs some info.

  Returns the atom :ok or an {:error, reason}

  ## Examples

      Plexy.Logger.info "hello?"
      Plexy.Logger.info [color: "purple"]
      Plexy.Logger.info %{sky: "blue"}
      Plexy.Logger.info fn -> hard_work_goes_here end
  """
  def info(datum_or_fn, metadata \\ [])
  def info(datum, metadata) when is_list(datum) or is_map(datum) do
    info(fn -> list_to_line(datum) end, metadata)
  end
  def info(chardata_or_fn, metadata), do: Logger.info(chardata_or_fn, metadata)

  @doc """
  Logs a warning.

  Returns the atom :ok or an {:error, reason}

  ## Examples

      Plexy.Logger.warn "hello?"
      Plexy.Logger.warn [color: "purple"]
      Plexy.Logger.warn %{sky: "blue"}
      Plexy.Logger.warn fn -> hard_work_goes_here end
  """
  def warn(datum_or_fn, metadata \\ [])
  def warn(datum, metadata) when is_list(datum) or is_map(datum) do
    warn(fn -> list_to_line(datum) end, metadata)
  end
  def warn(chardata_or_fn, metadata), do: Logger.warn(chardata_or_fn, metadata)

  @doc """
  Logs some debug info.

  Returns the atom :ok or an {:error, reason}

  ## Examples

      Plexy.Logger.debug "hello?"
      Plexy.Logger.debug [color: "purple"]
      Plexy.Logger.debug %{sky: "blue"}
      Plexy.Logger.debug fn -> hard_work_goes_here end
  """
  def debug(datum_or_fn, metadata \\ [])
  def debug(datum, metadata) when is_list(datum) or is_map(datum) do
    debug(fn -> list_to_line(datum) end, metadata)
  end
  def debug(chardata_or_fn, metadata), do: Logger.debug(chardata_or_fn, metadata)

  @doc """
  Logs a message.

  Returns the atom :ok or an {:error, reason}

  ## Examples

      Plexy.Logger.error "hello?"
      Plexy.Logger.error [color: "purple"]
      Plexy.Logger.error %{sky: "blue"}
      Plexy.Logger.error fn -> hard_work_goes_here end
  """
  def error(datum_or_fn, metadata \\ [])
  def error(datum, metadata) when is_list(datum) or is_map(datum) do
    error(fn -> list_to_line(datum) end, metadata)
  end
  def error(chardata_or_fn, metadata), do: Logger.error(chardata_or_fn, metadata)

  @doc """
  Logs a debug message with the given metric as a count

  ## Examples

      Plexy.Logger.count(:signup, 2)
      Plexy.Logger.count("registration", 1)
  """
  def count(metric, count) do
    debug(%{metric_name(metric, :count) => count})
  end

  @doc """
  Logs a debug message the amount of time in milliseconds required to run
  the given function and tags it as `metric`.

  ## Examples

      Plexy.Logger.count(:call_core, &super_slow_call/0)
      Plexy.Logger.count("rebuild", fn -> rebuild_the_invoice end)
  """
  def measure(metric, fun) do
    {time, result} = :timer.tc(fun)
    debug(%{metric_name(metric, :measure) => time / 1000.0})
    result
  end

  @doc """
  Log using the given level and data. This function should be avoided in
  favor of `.info`, `.warn`, `.debug`, `.error`, because they are removed
  at compile time.
  """
  def log(level, datum_or_fn, metadata \\ [])
  def log(level, datum, metadata) when is_list(datum) or is_map(datum) do
    log(level, fn -> list_to_line(datum) end, metadata)
  end
  def log(level, chardata_or_fn, metadata), do: Logger.log(level, chardata_or_fn, metadata)

  defp metric_name(metric, name) when is_atom(metric) do
    metric |> Atom.to_string |> metric_name(name)
  end

  defp metric_name(metric, name) do
    app = System.get_env("APP_NAME") || "plexy"
    name = Atom.to_string(name)
    "#{name}##{app}.#{metric}"
  end

  defp list_to_line(datum) when is_list(datum) or is_map(datum) do
    datum
    |> Enum.reduce("", &pair_to_segment/2)
    |> String.trim_trailing(" ")
  end

  defp pair_to_segment({k, v}, acc) when is_atom(k) do
    pair_to_segment({Atom.to_string(k), v}, acc)
  end

  defp pair_to_segment({k, v}, acc) when is_binary(v) or is_number(v) do
    "#{acc}#{k}=#{v} "
  end

  defp pair_to_segment({k, v}, acc) do
    pair_to_segment({k, inspect(v)}, acc)
  end
end
