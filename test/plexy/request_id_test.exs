defmodule Plexy.RequestIdTest do
  use ExUnit.Case, async: true

  alias Plexy.RequestId

  test "init has default config" do
    config = RequestId.init([])

    assert Keyword.get(config, :req_headers) == ["request-id", "x-request-id"]
    assert Keyword.get(config, :res_header) == "request-id"
  end

  test "init allows config" do
    config =
      RequestId.init(
        req_headers: ["my-foo-header"],
        res_header: "foobar-header"
      )

    assert Keyword.get(config, :req_headers) == ["my-foo-header"]
    assert Keyword.get(config, :res_header) == "foobar-header"
  end

  test "adds a request id header when none exists" do
    conn =
      %Plug.Conn{}
      |> RequestId.call(RequestId.init([]))

    header = hd(Plug.Conn.get_resp_header(conn, "request-id"))

    assert Regex.match?(~r/[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}/, header)
  end

  test "adds a request id header when one already exists" do
    conn =
      %Plug.Conn{req_headers: [{"request-id", "1234-abc"}]}
      |> RequestId.call(RequestId.init([]))

    header = hd(Plug.Conn.get_resp_header(conn, "request-id"))

    assert Regex.match?(~r/[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}/, header)
    assert String.ends_with?(header, ",1234-abc")
  end

  test "keeps all existing request ids when mulitple exist" do
    conn =
      %Plug.Conn{
        req_headers: [
          {"request-id", "1234-abcd"},
          {"request-id", "5678-efgh"},
          {"x-request-id", "9876-zyxw,5432-vuts"}
        ]
      }
      |> RequestId.call(RequestId.init([]))

    request_id = hd(Plug.Conn.get_resp_header(conn, "request-id"))

    assert String.contains?(request_id, "1234-abcd,5678-efgh")
    assert String.contains?(request_id, "9876-zyxw,5432-vuts")

    assert length(String.split(request_id, ",")) == 5
  end

  test "adds request_id to conn assigns" do
    conn =
      %Plug.Conn{}
      |> RequestId.call(RequestId.init([]))

    assert Regex.match?(
             ~r/[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}/,
             conn.assigns.request_id
           )
  end

  test "adds request_ids to conn assigns" do
    conn =
      %Plug.Conn{}
      |> RequestId.call(RequestId.init([]))

    assert Regex.match?(
             ~r/[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}/,
             hd(conn.assigns.request_ids)
           )
  end
end
