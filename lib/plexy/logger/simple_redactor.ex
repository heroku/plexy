defmodule Plexy.Logger.SimpleRedactor do
  @moduledoc """
  SimpleRedactor is able to filter and redact sensitive data.
  """

  @doc """
  Assuming line is in the format "key=value"

  - redact the values for all "keys" under `opts` :redact
  - filter out the entire line if it has a "key" under `opts` :filter

  ## Examples

      iex> SimpleRedactor.run("username=bob age=21", redact: ["username"])
      {:cont, "username=REDACTED age=21"}
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
    redacted =
      Enum.reduce(keys, line, fn k, l ->
        with {:ok, quoted} <- Regex.compile("#{k}=\"[^\"]+\"(\s?)"),
             {:ok, nquoted} <- Regex.compile("#{k}=[^\s]+(\s?)") do
          quoted_redacted = Regex.replace(quoted, l, "#{k}=REDACTED\\1")
          Regex.replace(nquoted, quoted_redacted, "#{k}=REDACTED\\1")
        end
      end)

    {:cont, redacted}
  end

  defp filter(line, []), do: {:cont, line}

  defp filter(line, keys) do
    line =
      Enum.reduce_while(keys, line, fn k, l ->
        if String.contains?(l, "#{k}=") do
          {:halt, ""}
        else
          {:cont, l}
        end
      end)

    {:cont, line}
  end
end
