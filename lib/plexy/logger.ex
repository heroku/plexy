defmodule Plexy.Logger do
  @moduledoc """
  Plexy.Logger is a proxy to Elixir's built-in logger that knows how to
  handle non char-data and has a few other helpful logging functions.
  """

  require Logger

  @overrides [:info, :warn, :debug, :error]

  for name <- @overrides do
    @doc """
    Logs a #{name} message.

    Returns the atom :ok or an {:error, reason}

    ## Examples

        Plexy.Logger.#{name} "hello?"
        Plexy.Logger.#{name} [color: "purple"]
        Plexy.Logger.#{name} %{sky: "blue"}
        Plexy.Logger.#{name} fn -> hard_work_goes_here end
    """
    def unquote(name)(datum_or_fn, metadata \\ []) do
      case datum_or_fn do
        datum when is_list(datum) or is_map(datum) ->
          Logger.unquote(name)(fn -> list_to_line(datum) end, metadata)

        datum ->
          Logger.unquote(name)(fn -> redact(datum) end, metadata)
      end
    end
  end

  @doc """
  Logs a debug message with the given metric as a count

  ## Examples

      Plexy.Logger.count(:signup, 2)
      Plexy.Logger.count("registration", 1)
      Plexy.Logger.count("registration") # same as above
  """
  def count(metric, count \\ 1) do
    debug(%{metric_name(metric, :count) => count})
  end

  @doc """
  Logs a debug message and tags it as `metric`.

  ## Examples

      Plexy.Logger.measure(:request, 200)
  """
  def measure(metric, time) when is_number(time) do
    debug(%{metric_name(metric, :measure) => time})
  end

  @doc """
  Logs a debug message the amount of time in milliseconds required to run
  the given function and tags it as `metric`.

  ## Examples

      Plexy.Logger.measure(:call_core, &super_slow_call/0)
      Plexy.Logger.measure("rebuild", fn -> rebuild_the_invoice end)
  """
  def measure(metric, fun) do
    {time, result} = :timer.tc(fun)
    measure(metric, time / 1000.0)
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
    metric |> to_string |> metric_name(name)
  end

  defp metric_name(metric, name) do
    app = System.get_env("APP_NAME") || "plexy"
    name = to_string(name)
    "#{name}##{app}.#{metric}"
  end

  defp list_to_line(datum) when is_list(datum) or is_map(datum) do
    datum
    |> Enum.reduce("", &pair_to_segment/2)
    |> String.trim_trailing(" ")
    |> redact
  end

  defp redact(line) when is_binary(line) do
    :plexy
    |> Application.get_env(:logger, [])
    |> Keyword.get(:redactors, [])
    |> Enum.reduce_while(line, fn {redactor, opts}, l ->
      redactor.run(l, opts)
    end)
  end

  defp pair_to_segment({k, v}, acc) when is_atom(k) do
    pair_to_segment({to_string(k), v}, acc)
  end

  defp pair_to_segment({k, v}, acc) when is_binary(v) do
    if String.contains?(v, " ") do
      "#{acc}#{k}=#{inspect(v)} "
    else
      "#{acc}#{k}=#{v} "
    end
  end

  defp pair_to_segment({k, v}, acc) do
    pair_to_segment({k, inspect(v)}, acc)
  end
end
