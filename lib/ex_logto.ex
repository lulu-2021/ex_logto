defmodule ExLogto do
  @moduledoc false

  import ExLogto.Generator
  alias ExLogto.{Client, ClientConfig, Core, RequestUtils, Token}

  @doc """
    here the redirect_url should be the callback url in our app..
  """
  def sign_in(code_verifier, code_challenge, state) do
    ClientConfig.callback_url()
    |> Client.sign_in(code_challenge, code_verifier, state)
    |> case do
      {:ok, sign_in_uri} ->
        {:ok, sign_in_uri}

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
    handle the sign out process
  """
  def sign_out do
    case Client.sign_out() do
      {:ok, logout_url} ->
        {:ok, logout_url}

      {:error, error} ->
        {:error, error}
    end
  end

  def handle_signin_callback(session, callback_uri) do
    code_verifier = get_code_verifier(session)
    code = Core.get_code_from_callback_uri(callback_uri)

    ClientConfig.callback_url()
    |> Client.process_callback(code_verifier, code)
    |> case do
      {:ok, token_map} ->
        token_map
        |> decode_token()
        |> user_info()

      {:error, message} ->
        # IO.inspect message, label: "signing callback failed"
        {:error, message}
    end
  end

  def refresh_token(refresh_token) do
    %{
      refresh_token: refresh_token,
      client_id: ClientConfig.client_id(),
      client_secret: ClientConfig.client_secret(),
      token_endpoint: ClientConfig.token_endpoint()
    }
    |> Core.fetch_token_by_refresh_token()
    |> case do
      {:ok, refreshed_token_map} ->
        refreshed_token_map
        |> decode_token()
        |> user_info()

      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_origin_request_url(conn), do: RequestUtils.get_origin_request_url(conn)

  def code_verifier, do: generate_code_verifier()

  def code_challenge(code_verifier), do: generate_code_challenge(code_verifier)

  def state, do: generate_state()

  def authenticated?(conn) do
    session_tokens =
      conn.private.plug_session
      |> session_tokens()

    session_tokens != nil
  end

  # ------ private functions -------#

  defp session_tokens(%{"tokens" => tokens}), do: tokens

  defp get_code_verifier(%{"code_verifier" => code_verifier}), do: code_verifier

  defp user_info(%{access_token: access_token} = data) do
    access_token
    |> Core.fetch_user_info()
    |> case do
      {:ok, user_info} ->
        # IO.inspect user_info, label: "user info"
        {:ok, Map.put(data, :user_info, user_info)}

      {:error, error} ->
        # IO.inspect error, label: "user info fetch failed"
        {:error, error}
    end
  end

  defp decode_token(%{
         "id_token" => id,
         "refresh_token" => refresh,
         "access_token" => access,
         "expires_in" => exp
       }) do
    id
    |> Token.unpack_token()
    |> Token.decode_token()
    |> case do
      {:ok, decoded_id_token} ->
        %{
          access_token: access,
          id_token: decoded_id_token,
          refresh_token: refresh,
          expires_in: exp,
          expires_at: :os.system_time(:seconds) + exp
        }

      {:error, error} ->
        {:error, error}
    end
  end
end
