defmodule Plexy.RequestId do
  alias Plug.Conn
  @behaviour Plug

  def init(opts) do
    %{req_headers:
        Keyword.get(opts, :req_headers, ["request-id", "x-request-id"]),
      res_header:
        Keyword.get(opts, :res_header, "request-id")}
  end

  def call(conn, config) do
    conn
    |> get_request_ids(Map.get(config, :req_headers))
    |> set_request_ids(Map.get(config, :res_header))
  end

  defp get_request_ids(conn, req_headers) do
    {conn, Enum.join(req_headers, &get_request_id(conn, &1), ",")}
  end

  defp get_request_id(conn, header) do
    case Conn.get_req_header(conn, header) |> String.split(",") do
      [h | t] -> [Ecto.UUID.generate() | [h | t]]
      _       -> [Ecto.UUID.generate()]
    end
  end

  defp set_request_ids({conn, request_ids}, header) do
    conn = Conn.put_resp_header(conn, header, request_ids)
    %{conn | request_id: Enum.first(request_ids),
             request_ids: request_ids}
  end
end
