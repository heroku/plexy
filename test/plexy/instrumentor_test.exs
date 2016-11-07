defmodule Plexy.InstrumentorTest do
  use ExUnit.Case

  alias Plexy.Instrumentor

  test "init defaults level to :info" do
    level = Instrumentor.init([])
    assert level == :info
  end

  test "init allows level to be specified" do
    level = Instrumentor.init([log: :debug])
    assert level == :debug
  end
end
