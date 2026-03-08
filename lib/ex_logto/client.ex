defmodule ExLogto.Client do
  @moduledoc false

  alias ExLogto.{ClientConfig, Core}

  @doc """
  Signs in the user and returns the sign-in URI.
  The `redirect_uri` here is the redirect uri in our app
  """
  def sign_in(redirect_uri, code_challenge, code_verifier, state) do
    signin_options = ClientConfig.signin_options(code_challenge, state, redirect_uri)

    {:ok, sign_in_uri} = Core.generate_sign_in_uri(signin_options)

    sign_in_session = %{
      redirect_uri: redirect_uri,
      code_verifier: code_verifier,
      code_challenge: code_challenge,
      state: state
    }

    {:ok, sign_in_session_json_value} = Jason.encode(sign_in_session)
    storage = %{} |> Map.put(:storage_key_sign_in_session, sign_in_session_json_value)
    IO.inspect(storage, label: "session storage for later validation")

    {:ok, sign_in_uri}
  end

  def process_callback(redirect_uri, code_verifier, code) do
    options = %{
      token_endpoint: ClientConfig.token_endpoint(),
      client_id: ClientConfig.client_id(),
      client_secret: ClientConfig.client_secret(),
      redirect_uri: redirect_uri,
      code_verifier: code_verifier,
      code: code
    }

    Core.fetch_token_by_authorization_code(options)
  end

  def sign_out do
    options = %{
      client_id: ClientConfig.client_id(),
      end_session_endpoint: ClientConfig.end_session_endpoint(),
      post_logout_redirect_uri: ClientConfig.post_logout_redirect_url()
    }

    Core.generate_sign_out_uri(options)
  end
end
