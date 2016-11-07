defmodule Plexy.RequestIdTest do
  use ExUnit.Case

  alias Plexy.RequestId

  test "init has default config" do
    config = RequestId.init([])

    assert config.req_headers == ["request-id", "x-request-id"]
    assert config.res_header == "request-id"
  end

  test "init allows config" do
    config = RequestId.init(req_headers: ["my-foo-header"])

    assert config.req_headers == ["my-foo-header"]
  end
end
