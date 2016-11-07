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
    ids = Enum.map(req_headers, &get_request_id(conn, &1))
          |> Enum.filter(&(&1))
          |> Enum.flat_map(&(&1))
    {conn, [Ecto.UUID.generate() | ids]}
  end

  defp get_request_id(conn, header) do
    Conn.get_req_header(conn, header)
    |> Enum.flat_map(&String.split(&1, ","))
  end

  defp set_request_ids({conn, request_ids}, header) do
    string = Enum.join(request_ids, ",")
    conn = Conn.put_resp_header(conn, header, string)
    assigns = Map.put(conn.assigns, :request_id, hd(request_ids))
              |> Map.put(:request_ids, request_ids)
    %{conn | assigns: assigns}
  end
end
