defmodule ExLogto.ClientConfig do
  @moduledoc """
    all the configuration options handled in one place - the scopes
  """
alias ElixirLS.LanguageServer.Application

  @default_prompt "consent"
  @default_scopes ["openid", "offline_access", "email", "profile"]
  @default_resources []

  def signin_options(code_challenge, state, redirect_uri) do
    %{
      code_challenge: code_challenge,
      authorization_endpoint: authorization_endpoint(),
      client_id: client_id(),
      redirect_uri: redirect_uri,
      state: state,
      scopes: scopes(),
      resources: resources(),
      prompt: prompt()
    }
  end

  def scopes, do: Application.get_env(:ex_logto, :scopes) || @default_scopes
  def resources, do: Application.get_env(:ex_logto, :resources) || @default_resources
  def prompt, do: Application.get_env(:ex_logto, :prompt) || @default_prompt

  def callback_url, do: Application.get_env(:ex_logto, :callback_url)
  def client_id, do: Application.get_env(:ex_logto, :client_id)
  def client_secret, do: Application.get_env(:ex_logto, :client_secret)

  def authorization_endpoint, do: Application.get_env(:ex_logto, :authorization_endpoint)
  def token_endpoint, do: Application.get_env(:ex_logto, :token_endpoint)

  def end_session_endpoint, do: Application.get_env(:ex_logto, :end_session_endpoint)

  def post_logout_redirect_url, do: Application.get_env(:ex_logto, :post_logout_redirect_url)
  def user_info_endpoint, do: Application.get_env(:ex_logto, :user_info_endpoint)
end
