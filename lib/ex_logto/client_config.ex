defmodule ExLogto.ClientConfig do
  @moduledoc """
  """

  @callback_url "http://lvh.me:4000/page/callback"
  @authorization_endpoint "http://localhost:3001/oidc/auth/"
  @token_endpoint "http://localhost:3001/oidc/token/"
  @user_info_endpoint "http://localhost:3001/oidc/me/"
  @end_session_endpoint "http://localhost:3001/oidc/session/end"
  @post_logout_redirect_url "http://lvh.me:4000/"
  @client_id "2a2yi37r08mv2ujr0dhf8"
  @client_secret "qPl7Oc8Dxi1VGDDJwYpKjlL7WX99Xemj"
  @prompt "consent"

  def signin_options(code_challenge, state, redirect_uri) do
    %{
      code_challenge: code_challenge,
      authorization_endpoint: @authorization_endpoint,
      client_id: @client_id,
      redirect_uri: redirect_uri,
      state: state,
      scopes: ["openid", "offline_access", "email", "profile"],
      resources: [],
      prompt: @prompt
    }
  end

  def callback_url, do: @callback_url

  def client_id, do: @client_id
  def client_secret, do: @client_secret
  def token_endpoint, do: @token_endpoint

  def end_session_endpoint, do: @end_session_endpoint

  def post_logout_redirect_url, do: @post_logout_redirect_url
  def user_info_endpoint, do: @user_info_endpoint
end
