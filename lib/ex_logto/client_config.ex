defmodule ExLogto.ClientConfig do
  @moduledoc """
    all the configuration options handled in one place - the scopes
  """

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

  def scopes, do: logto_config()[:scopes] || @default_scopes
  def resources, do: logto_config()[:resources] || @default_resources
  def prompt, do: logto_config()[:prompt] || @default_prompt

  def callback_url, do: logto_config()[:callback_url]
  def post_logout_redirect_url, do: logto_config()[:post_logout_redirect_url]

  def client_id, do: logto_config()[:client_id]
  def client_secret, do: logto_config()[:client_secret]

  def id_server_base, do: logto_config()[:id_server_base]
  def id_server_port, do: logto_config()[:id_server_port]

  def authorization_endpoint, do: logto_config()[:authorization_endpoint] |> build_url()
  def token_endpoint, do: logto_config()[:token_endpoint] |> build_url()
  def end_session_endpoint, do: logto_config()[:end_session_endpoint] |> build_url()
  def user_info_endpoint, do: logto_config()[:user_info_endpoint] |> build_url()

  defp logto_config(), do: Application.get_env(:ex_logto, :ex_logto_options)

  # ---------- private functions ---------- #

  defp build_url(endpoint) do
    "#{id_server_base()}:#{id_server_port()}#{endpoint}"
  end
end
