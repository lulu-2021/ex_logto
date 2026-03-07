defmodule ExLogto.RequestUtils do
  @moduledoc false

  @doc """
    Generates the origin request URL based on the given HTTP request.

    ## Parameters
      `conn`: the HTTP request struct

    ## Returns
      The origin request URL as a string.
  """
  def get_origin_request_url(conn) do
    port = "#{conn.port}"
    path = conn.request_path
    queries = conn.query_string

    conn.scheme
    |> ExLogto.UrlUtils.clean_url(conn.host, port, path, queries)
  end
end
