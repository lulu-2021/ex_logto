defmodule ExLogto.UrlUtils do
  @moduledoc false

  @doc """
  """

  def clean_url("https", host, _port, path), do: "https://#{host}#{path}"

  def clean_url(_scheme, host, _port, path), do: "https://#{host}#{path}"

  def clean_url("https", host, _port, path, queries), do: "https://#{host}#{path}?#{queries}"

  def clean_url(_scheme, host, _port, path, queries),
    do: "https://#{host}#{path}?#{queries}"
end
