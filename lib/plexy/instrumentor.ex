defmodule Plexy.Instrumentor do
  @moduledoc """
  A plug for logging basic request information in the format:
  instrumentation at=start method=get path=/apps
  instrumentation at=finish method=get path=/apps elapsed=100 status=200
  """
  alias Plug.Conn
  alias Plexy.Logger
  @behaviour Plug

  @doc """
  Initializes the plug. Log level is supported with :log.
  """
  def init(opts) do
    Keyword.get(opts, :log, :info)
  end

  @doc """
  Logs the current request details when the plug is called, and logs the
  request timing and status before the response is sent.
  """
  def call(conn, level) do
    context = [
      instrumentation: true,
      method: conn.method,
      path: conn.request_path
    ]

    Logger.log(level, Keyword.merge(context, at: "start"))

    start = :erlang.monotonic_time()

    Conn.register_before_send(conn, fn conn ->
      stop = :erlang.monotonic_time()
      diff = :erlang.convert_time_unit(stop - start, :native, :milli_seconds)

      Logger.log(
        level,
        Keyword.merge(context,
          at: "finish",
          elapsed: diff,
          status: conn.status
        )
      )

      conn
    end)
  end
end
