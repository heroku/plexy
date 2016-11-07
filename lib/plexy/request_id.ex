defmodule Plexy.RequestId do
  @moduledoc """
  A plug that reads from specified :req_headers for given request ids,
  prepends a new generated one, and adds all as a comma seperated list to the
  specified res_header.
  """
  alias Plug.Conn
  @behaviour Plug

  @default_headers ["request-id", "x-request-id"]

  @doc """
  Initializes the plug. Returns a configuration map with specified
  :req_headers and :res_headers for use by the other functions.
  """
  def init(opts) do
    req_headers = case Keyword.get(opts, :req_headers, @default_headers) do
        v when is_list(v) -> v
        v when is_binary(v) -> [v]
      end

    %{req_headers: req_headers,
      res_header:  Keyword.get(opts, :res_header, "request-id")}
  end

  @doc """
  Reads :res_headers, injects a new uuid, than adds them all to the specified
  :res_headers and the conn's :assigns
  """
  def call(conn, config) do
    conn
    |> get_request_ids(Map.get(config, :req_headers))
    |> set_request_ids(Map.get(config, :res_header))
  end

  # Reads the given headers for request ids, turns them into a list of binaries,
  # and prepends the new request id
  defp get_request_ids(conn, req_headers) do
    ids = Enum.reduce(req_headers, [], fn(header, acc) ->
      case get_request_id(conn, header) do
        []      -> acc
        headers -> acc ++ headers
      end
    end)
    {conn, [UUID.uuid1() | ids]}
  end

  # Gets a list of request ids for a single header.
  defp get_request_id(conn, header) do
    conn
    |> Conn.get_req_header(header)
    |> Enum.flat_map(&String.split(&1, ","))
  end

  # Sets the request ids as the res_header, and adds it to conn.assigns
  defp set_request_ids({conn, request_ids}, header) do
    string = Enum.join(request_ids, ",")
    conn = Conn.put_resp_header(conn, header, string)
    assigns =
      conn.assigns
      |> Map.put(:request_id, hd(request_ids))
      |> Map.put(:request_ids, request_ids)
    %{conn | assigns: assigns}
  end
end
