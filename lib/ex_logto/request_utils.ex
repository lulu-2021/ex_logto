defmodule ExLogto.RequestUtils do
  @doc """
    Generates the origin request URL based on the given HTTP request.

    ## Parameters
      `conn`: the HTTP request struct

    ## Returns
      The origin request URL as a string.
  """
  def get_origin_request_url(conn) do
    request_protocol(conn) <>
      "://" <>
      conn.host <> ":" <> conn_port(conn) <> conn.request_path <> "/?" <> conn.query_string
  end

  # ----------- private functions ----------- #

  defp conn_port(conn), do: "#{conn.port}"

  defp request_protocol(conn) do
    case conn.scheme do
      "https" -> "https"
      _ -> "http"
    end
  end
end
