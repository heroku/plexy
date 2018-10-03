defmodule Plexy.InstrumentorTest do
  alias Plexy.Instrumentor
  import ExUnit.CaptureLog
  use ExUnit.Case
  use Plug.Test

  test "Instrumentor.init/1 defaults level to :info" do
    level = Instrumentor.init([])
    assert level == :info
  end

  test "Instrumentor.init/1 allows level to be specified" do
    level = Instrumentor.init(log: :debug)
    assert level == :debug
  end

  @opts Instrumentor.init([])
  test "Instrumentor.call/2 logging" do
    logged =
      capture_log(fn ->
        conn(:get, "/foobar")
        |> Instrumentor.call(@opts)
        |> Plug.Conn.send_resp(200, "wow")
      end)

    [start_log_line, measure_log_line, finish_log_line | _empty_list] = String.split(logged, "\n")

    assert start_log_line =~ "instrumentation"
    assert start_log_line =~ "start"
    assert start_log_line =~ "path"
    assert start_log_line =~ "method"

    assert measure_log_line =~ "measure"
    assert measure_log_line =~ "request.latency.milliseconds"

    assert finish_log_line =~ "instrumentation"
    assert finish_log_line =~ "finish"
    assert finish_log_line =~ "elapsed"
    assert finish_log_line =~ "status"
    assert finish_log_line =~ "path"
    assert finish_log_line =~ "method"
  end
end
