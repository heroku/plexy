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

    assert start_log_line =~ "instrumentation=true"
    assert start_log_line =~ "at=start"
    assert start_log_line =~ "path=/foobar"
    assert start_log_line =~ "method=GET"

    assert measure_log_line =~ "measure#plexy.request.latency.ms"

    assert finish_log_line =~ "instrumentation=true"
    assert finish_log_line =~ "at=finish"
    assert finish_log_line =~ "path=/foobar"
    assert finish_log_line =~ "method=GET"
    assert finish_log_line =~ "status=200"
    assert finish_log_line =~ "elapsed"
  end
end
