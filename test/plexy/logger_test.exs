defmodule Plexy.LoggerTest do
  use ExUnit.Case

  alias Plexy.Logger
  import ExUnit.CaptureLog

  @test_app_name "test-app-name"

  setup do
    Application.put_env(:plexy, :app_name, @test_app_name)
  end

  test "logs with keyword lists" do
    logged =
      capture_log(fn ->
        Logger.debug(foo: 1, test: "bar")
      end)

    assert logged =~ "foo=1"
    assert logged =~ "test=bar"
  end

  test "logs regular strings" do
    logged =
      capture_log(fn ->
        Logger.debug("foo=bar")
      end)

    assert logged =~ "foo=bar"
  end

  test "logs strings with spaces inside of quotes" do
    logged =
      capture_log(fn ->
        Logger.debug(foo: "bar baz")
      end)

    assert logged =~ "foo=\"bar baz\""
  end

  test "logs counts for a given metric" do
    logged =
      capture_log(fn ->
        Logger.count(:foo, 1)
      end)

    assert logged =~ "count##{@test_app_name}.foo=1"
  end

  test "logs counts for a given metric, assuming the count is one" do
    logged =
      capture_log(fn ->
        Logger.count(:foo)
      end)

    assert logged =~ "count##{@test_app_name}.foo=1"
  end

  test "logs time elapsed for given code block" do
    logged =
      capture_log(fn ->
        Logger.measure(:sleeping, fn ->
          :timer.sleep(100)
        end)
      end)

    assert logged =~ "measure##{@test_app_name}.sleeping.ms=1"
  end

  test "redacts configured keys" do
    logged =
      capture_log(fn ->
        Logger.debug(password: "mystuff")
      end)

    assert logged =~ "password=REDACTED"
  end

  test "filters configured keys" do
    logged =
      capture_log(fn ->
        Logger.debug(secret: "mystuff")
      end)

    refute logged =~ "secret"
  end

  test "includes app name, when provided" do
    logged =
      capture_log(fn ->
        Logger.debug(my_message: "mystuff", app: "passed-test-app-name")
      end)

    assert logged =~ "app=passed-test-app-name"
  end

  describe "when app name is not set in the config" do
    setup do
      Application.put_env(:plexy, :app_name, nil)
    end

    test "raises with an error message explaining that app_name be set" do
      assert_raise RuntimeError, ~r/must set app_name for/, fn ->
        Logger.debug(my_message: "mystuff", app: "passed-test-app-name")
      end
    end
  end
end
