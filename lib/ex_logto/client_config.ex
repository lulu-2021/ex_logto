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

  def scopes, do: Application.get_env(:ex_logto, __MODULE__, :scopes) || @default_scopes
  def resources, do: Application.get_env(:ex_logto, __MODULE__, :resources) || @default_resources
  def prompt, do: Application.get_env(:ex_logto, __MODULE__, :prompt) || @default_prompt

  def callback_url, do: Application.get_env(:ex_logto, __MODULE__, :callback_url)
  def post_logout_redirect_url, do: Application.get_env(:ex_logto, __MODULE__, :post_logout_redirect_url)

  def client_id, do: Application.get_env(:ex_logto, __MODULE__, :client_id)
  def client_secret, do: Application.get_env(:ex_logto, __MODULE__, :client_secret)

  def id_server_base, do: Application.get_env(:ex_logto, __MODULE__, :id_server_base)
  def id_server_port, do: Application.get_env(:ex_logto, __MODULE__, :id_server_port)
  def authorization_endpoint, do: Application.get_env(:ex_logto, __MODULE__, :authorization_endpoint) |> build_url()
  def token_endpoint, do: Application.get_env(:ex_logto, __MODULE__, :token_endpoint) |> build_url()

  def end_session_endpoint, do: Application.get_env(:ex_logto, __MODULE__, :end_session_endpoint) |> build_url()

  def user_info_endpoint, do: Application.get_env(:ex_logto, __MODULE__, :user_info_endpoint) |> build_url()

  defp build_url(endpoint) do
    "#{id_server_base()}#{id_server_port()}#{endpoint}"
  end
end
