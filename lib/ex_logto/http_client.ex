defmodule ExLogto.HttpClient do
  @moduledoc false
  @behaviour ExLogto.HttpClientBehaviour

  def post(url, body, headers, opts) do
    HTTPoison.post(url, body, headers, opts)
  end
end
