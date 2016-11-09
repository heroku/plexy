defmodule Plexy.Logger.SimpleRedactor do
  @moduledoc """
  SimpleRedactor is able to filter and redact sensative data
  """

  @doc """
  Assuming line is in the format "key=value"

  - redact the values for all "keys" under `opts` :redact
  - filter out the entire line if it has a "key" under `opts` :filter

  ## Examples

      iex> SimpleRedactor.run("username=bob", redact: ["username"])
      {:cont, "username=REDACTED"}
      iex> SimpleRedactor.run("password=mysecred", filter: ["password"])
      {:cont, ""}
  """
  def run("", _opts), do: {:halt, ""}
  def run(line, opts) do
    with {:cont, redacted} <- redact(line, Keyword.get(opts, :redact, [])),
         {:cont, filtered} <- filter(redacted, Keyword.get(opts, :filter, [])),
         do: {:cont, filtered}
  end

  defp redact(line, []), do: {:cont, line}
  defp redact(line, keys) do
    redacted = Enum.reduce(keys, line, fn (k, l) ->
      "#{k}=\"?[^\"]+\"?\s?"
      |> Regex.compile
      |> elem(1)
      |> Regex.replace(l, "#{k}=REDACTED")
    end)
    {:cont, redacted}
  end

  defp filter(line, []), do: {:cont, line}
  defp filter(line, keys) do
    line = Enum.reduce_while(keys, line, fn (k, l) ->
      if String.contains?(l, "#{k}=") do
        {:halt, ""}
      else
        {:cont, l}
      end
    end)
    {:cont, line}
  end
end
