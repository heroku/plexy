defmodule Plexy.Example do
  use Plug.Router
  plug Plexy.RequestId
  plug Plexy.Instrumentor
  plug :match
  plug :dispatch

  get "/hello" do
    Plexy.Logger.measure(:db_call, &make_db_call/0)

    send_resp(conn, Enum.random([200, 200, 200, 404, 500, 403, 201]), "world")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp make_db_call() do
    Plexy.Logger.info(test: true, foo: "bar")
    Plexy.Logger.count(:rpm, 3000)
    Plexy.Logger.count(:requests, 1)
    :timer.sleep(1)
  end
end
