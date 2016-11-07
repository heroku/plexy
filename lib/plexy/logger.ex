defmodule Plexy.Logger do
  require Logger

  def info(datum) when is_list(datum) or is_map(datum) do
    datum |> list_to_line |> info
  end

  def warn(datum) when is_list(datum) or is_map(datum) do
    datum |> list_to_line |> warn
  end

  def debug(datum) when is_list(datum) or is_map(datum) do
    datum |> list_to_line |> debug
  end

  def error(datum) when is_list(datum) or is_map(datum) do
    datum |> list_to_line |> error
  end

  def log(level, datum) when is_list(datum) or is_map(datum) do
    line = datum |> list_to_line
    log(level, line)
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
    |> Enum.reduce("", fn
      ({k, v}, acc) when is_atom(k) -> "#{acc}#{Atom.to_string(k)}=#{inspect(v)} "
      ({k, v}, acc) -> "#{acc}#{k}=#{inspect(v)} "
    end)
    |> String.trim_trailing(" ")
  end

  defdelegate info(str), to: Elixir.Logger
  defdelegate warn(str), to: Elixir.Logger
  defdelegate debug(str), to: Elixir.Logger
  defdelegate error(str), to: Elixir.Logger
  defdelegate log(level, str), to: Elixir.Logger
end
