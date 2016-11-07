defmodule Plexy.RequestId do
  @moduledoc """
  Injects a request id into the specified header for each request. Leaves
  existing request ids in tact.
  """
  alias Plug.Conn
  @behaviour Plug

  @doc """
  Initializes the plug. Returns a map with req_headers and
  res_headers for use by the other functions.
  """
  def init(opts) do
    req_headers = case Keyword.get(opts, :req_headers, ["request-id", "x-request-id"]) do
      v when is_list(v) -> v
      v when is_binary(v) -> [v]
    end

    %{req_headers: req_headers,
      res_header:  Keyword.get(opts, :res_header, "request-id")}
  end

  @doc """
  Takes the req_headers from the config and adds a UUID for our
  request header and then shoves that all into the response header
  also sets an assigns
  """
  def call(conn, config) do
    conn
    |> get_request_ids(Map.get(config, :req_headers))
    |> set_request_ids(Map.get(config, :res_header))
  end


  defp get_request_ids(conn, req_headers) do
    ids = Enum.reduce(req_headers, [], fn(header, acc) ->
      case get_request_id(conn, header) do
        []      -> acc
        headers -> acc ++ headers
      end
    end)
    {conn, [Ecto.UUID.generate() | ids]}
  end

  defp get_request_id(conn, header) do
    Conn.get_req_header(conn, header)
    |> List.flatten()
    |> Enum.map(&String.split(&1, ","))
    |> List.flatten()
  end

  defp set_request_ids({conn, request_ids}, header) do
    string = Enum.join(request_ids, ",")
    conn = Conn.put_resp_header(conn, header, string)
    assigns = Map.put(conn.assigns, :request_id, hd(request_ids))
              |> Map.put(:request_ids, request_ids)
    %{conn | assigns: assigns}
  end
end
