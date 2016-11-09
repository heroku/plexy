defmodule Plexy.InstrumentorTest do
  alias Plexy.Instrumentor
  import ExUnit.CaptureLog
  use ExUnit.Case, async: true
  use Plug.Test

  test "Instrumentor.init/1 defaults level to :info" do
    level = Instrumentor.init([])
    assert level == :info
  end

  test "Instrumentor.init/1 allows level to be specified" do
    level = Instrumentor.init([log: :debug])
    assert level == :debug
  end

  @opts Instrumentor.init([])
  test "Instrumentor.call/2 logs the start" do
    logged = capture_log(fn ->
      conn(:get, "/foobar") |> Instrumentor.call(@opts)
    end)

    assert logged =~ "instrumentation"
    assert logged =~ "start"
    assert logged =~ "path"
    assert logged =~ "method"
  end

  test "Instrumentor.call/2 logs the finish" do
    logged = capture_log(fn ->
      conn(:get, "/foobar")
      |> Instrumentor.call(@opts)
      |> Plug.Conn.send_resp(200, "wow")
    end)

    assert logged =~ "instrumentation"
    assert logged =~ "finish"
    assert logged =~ "elapsed"
    assert logged =~ "status"
    assert logged =~ "path"
    assert logged =~ "method"
  end
end
