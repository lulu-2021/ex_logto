defmodule ExLogto.Token do
  @moduledoc false

  @type id_token_claims :: map()

  @doc """
  Decodes a given JWT token and returns the claims.

  ## Parameters
  - token: The JWT token as a string.

  ## Returns
  - {:ok, id_token_claims} on success.
  - {:error, reason} on failure.
  """
  def unpack_token(token), do: JOSE.JWS.peek_payload(token)
  #def decode_token(token), do: Poison.decode(token, %{})
  def decode_token(token), do: Jason.decode(token, %{})
end
