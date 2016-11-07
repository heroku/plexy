defmodule Plexy.LoggerTest do
  use ExUnit.Case

  alias Plexy.Logger
  import ExUnit.CaptureLog

  test "logs with keyword lists" do
    logged = capture_log(fn ->
      Logger.debug(foo: 1, test: "bar")
    end)

    assert logged =~ "foo=1"
    assert logged =~ "test=\"bar\""
  end

  test "logs regular strings" do
    logged = capture_log(fn ->
      Logger.debug("foo=bar")
    end)

    assert logged =~ "foo=bar"
  end

  test "logs counts for a given metric" do
    logged = capture_log(fn ->
      Logger.count(:foo, 1)
    end)

    assert logged =~ "count#plexy.foo=1"
  end

  test "logs time elapsed for given code block" do
    # TODO: Figure out way to mock :timer.tc?
  end
end
