defmodule ExLogto.RequestUtilsTest do
  use ExUnit.Case
  alias ExLogto.RequestUtils

  test "get_origin_request_url builds correct URL for https scheme" do
    conn = %{
      scheme: "https",
      host: "example.com",
      port: 443,
      request_path: "/path",
      query_string: "a=1"
    }

    assert RequestUtils.get_origin_request_url(conn) == "https://example.com:443/path/?a=1"
  end

  test "get_origin_request_url builds http when scheme is not https" do
    conn = %{
      scheme: "http",
      host: "example.test",
      port: 8080,
      request_path: "/",
      query_string: ""
    }

    # Note: the implementation appends "/?" after request_path, so "/" becomes "//?"
    assert RequestUtils.get_origin_request_url(conn) == "http://example.test:8080//?"
  end
end
