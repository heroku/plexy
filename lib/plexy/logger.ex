defmodule Plexy.Logger do
  require Logger

  def info(datum, meta \\ [])
  def info(datum, meta) when is_list(datum) or is_map(datum) do
    datum |> list_to_line |> info(meta)
  end

  def warn(datum, meta \\ [])
  def warn(datum, meta) when is_list(datum) or is_map(datum) do
    datum |> list_to_line |> warn(meta)
  end

  def debug(datum, meta \\ [])
  def debug(datum, meta) when is_list(datum) or is_map(datum) do
    datum |> list_to_line |> debug(meta)
  end

  def error(datum, meta \\ [])
  def error(datum, meta) when is_list(datum) or is_map(datum) do
    datum |> list_to_line |> error(meta)
  end

  def log(level, datum, meta \\ [])
  def log(level, datum, meta) when is_list(datum) or is_map(datum) do
    line = datum |> list_to_line
    log(level, line, meta)
  end

  def measure(metric, fun) do
    {time, result} = :timer.tc(fun)
    debug(%{metric_name(metric, :measure) => time / 0.001})
    result
  end

  def count(metric, cnt) do
    debug(%{metric_name(metric, :count) => cnt})
  end

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

  defdelegate info(str, meta), to: Elixir.Logger
  defdelegate warn(str, meta), to: Elixir.Logger
  defdelegate debug(str, meta), to: Elixir.Logger
  defdelegate error(str, meta), to: Elixir.Logger
  defdelegate log(level, str, meta), to: Elixir.Logger
end
