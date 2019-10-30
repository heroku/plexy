defmodule Plexy.InstrumentorTest do
  alias Plexy.Instrumentor
  alias Plug.Conn
  import ExUnit.CaptureLog
  use ExUnit.Case
  use Plug.Test

  @test_app_name "test-app-name"

  setup do
    Application.put_env(:plexy, :app_name, @test_app_name)
  end

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
        |> Conn.send_resp(203, "wow")
      end)

    [
      start_log_line,
      measure_log_line,
      status_log_line,
      status_class_log_line,
      finish_log_line
      | _anything_else
    ] = String.split(logged, "\n")

    assert start_log_line =~ "app=#{@test_app_name}"
    assert start_log_line =~ "instrumentation=true"
    assert start_log_line =~ "at=start"
    assert start_log_line =~ "path=/foobar"
    assert start_log_line =~ "method=GET"

    assert measure_log_line =~ "measure##{@test_app_name}.requests.latency.ms"

    assert status_log_line =~ "count##{@test_app_name}.requests.203"
    assert status_class_log_line =~ "count##{@test_app_name}.requests.2xx"

    assert finish_log_line =~ "app=#{@test_app_name}"
    assert finish_log_line =~ "instrumentation=true"
    assert finish_log_line =~ "at=finish"
    assert finish_log_line =~ "path=/foobar"
    assert finish_log_line =~ "method=GET"
    assert finish_log_line =~ "status=203"
    assert finish_log_line =~ "elapsed"
  end
end
