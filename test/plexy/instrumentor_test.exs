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
    level = Instrumentor.init([log: :debug])
    assert level == :debug
  end

  @opts Instrumentor.init([])
  test "Instrumentor.call/2 logs the start" do

    logged = capture_log(fn ->
      conn = conn(:get, "/foobar/foo-az")
             |> Instrumentor.call(@opts)
    end)

    assert logged =~ "instrumentation"
    assert logged =~ "at: \"start\""
  end
end
