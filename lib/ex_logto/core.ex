defmodule ExLogto.Core do
  @moduledoc """
    - Module for generating sign-in URIs.
    - Module for handling the verification and parsing of the code from the callback URI.
    - This module provides functions to fetch access tokens using the authorization code flow
      and refresh token flow.
  """

  @default_scopes []
  require HTTPoison

  alias ExLogto.ClientConfig

  @doc """
  Generates a sign-in URI based on the provided options.

  ## Parameters

  - `options`: a `SignInUriGenerationOptions` struct containing the necessary options for generating the sign-in URI.

  ## Returns

  - `{:ok, uri}`: the generated sign-in URI.
  - `{:error, reason}`: an error tuple with the reason for the failure.
  """
  def generate_sign_in_uri(%{
        authorization_endpoint: authorization_endpoint,
        client_id: client_id,
        redirect_uri: redirect_uri,
        code_challenge: code_challenge,
        state: state,
        scopes: scopes,
        resources: resources,
        prompt: prompt
      }) do
    with {:ok, uri} <- parse_url(authorization_endpoint),
         queries = build_queries(uri, client_id, redirect_uri, code_challenge, state, scopes, resources, prompt),
         {:ok, unescaped_queries} <- url_unescape(queries) do
      {:ok, "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}?#{unescaped_queries}"}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
    generate a uri for signing out
  """
  def generate_sign_out_uri(options) do
    case parse_url(options.end_session_endpoint) do
      {:ok, uri} ->
        queries = uri.query
        |> build_logout_query(options)

        logout_url = "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}?#{queries}"

        {:ok, logout_url}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Verifies and parses the code from the callback URI.

  Args:
    - callback_uri (String.t): The callback URI.
    - redirect_uri (String.t): The redirect URI.
    - state (String.t): The state.

  Returns:
    - {:ok, code} (tuple): The code if the verification is successful.
    - {:error, reason} (tuple): The error reason if the verification fails.
  """
  def get_code_from_callback_uri(callback_uri) do
    uri = callback_uri
    |> URI.parse()

    decoded = uri.query
    |> URI.decode_query()

    %{"code" => code} = decoded

    code
  end

  @doc """
  Fetches an access token using the authorization code flow.

  ## Options

  - `:token_endpoint` - The token endpoint URL.
  - `:code` - The authorization code.
  - `:code_verifier` - The code verifier.
  - `:client_id` - The client ID.
  - `:client_secret` - The client secret.
  - `:redirect_uri` - The redirect URI.
  - `:resource` - The resource (optional).

  Returns a `%{access_token: ..., refresh_token: ..., ...}` map on success, or an error tuple.
  """
  def fetch_token_by_authorization_code(options) do
    body =
      URI.encode_query(%{
        client_id: options[:client_id],
        redirect_uri: options[:redirect_uri],
        code_verifier: options[:code_verifier],
        code: options[:code],
        grant_type: "authorization_code"
      })
      |> Kernel.<>((if options[:resource], do: "&resource=#{options[:resource]}", else: ""))

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    auth =
      if options[:client_secret],
        do: [hackney: [basic_auth: {options[:client_id], options[:client_secret]}]],
        else: []

    case HTTPoison.post(options[:token_endpoint], body, headers, auth) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "HTTP #{status_code}: #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Fetches an access token using the refresh token flow.

  ## Options

  - `:token_endpoint` - The token endpoint URL.
  - `:client_id` - The client ID.
  - `:client_secret` - The client secret.
  - `:refresh_token` - The refresh token.
  - `:resource` - The resource (optional).
  - `:scopes` - A list of scopes (optional).
  - `:organization_id` - The organization ID (optional).

  Returns a `%{access_token: ..., refresh_token: ..., ...}` map on success, or an error tuple.
  """
  def fetch_token_by_refresh_token(options) do
    body =
      URI.encode_query(%{
        client_id: options[:client_id],
        refresh_token: options[:refresh_token],
        grant_type: "refresh_token"
      })
      |> Kernel.<>((if options[:resource], do: "&resource=#{options[:resource]}", else: ""))
      |> Kernel.<>((if options[:scopes], do: "&scope=#{Enum.join(options[:scopes], " ")}", else: ""))
      |> Kernel.<>((if options[:organization_id], do: "&organization_id=#{options[:organization_id]}", else: ""))

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    auth =
      if options[:client_secret],
        do: [hackney: [basic_auth: {options[:client_id], options[:client_secret]}]],
        else: []

    case HTTPoison.post(options[:token_endpoint], body, headers, auth) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "HTTP #{status_code}: #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def fetch_user_info(access_token) do
    headers = [{"Authorization", "Bearer #{access_token}"}]

    ClientConfig.user_info_endpoint()
    |> HTTPoison.get(headers)
    |> case  do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body, as: %{})}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  # ---------- private functions ---------- #

  defp build_logout_query(query, options) do
    query
    |> decode_query()
    |> Map.put("cliend_id", options.client_id)
    |> add_post_logout_uri_to_queries(options)
    |> IO.inspect()
    |> uri_encode_queries()
  end

  defp add_post_logout_uri_to_queries(queries, options) do
    if options.post_logout_redirect_uri != "" do
      Map.put(queries, "post_logout_redirect_uri", options.post_logout_redirect_uri)
    else
      queries
    end
  end

  defp uri_encode_queries(queries), do: URI.encode_query(queries)

  defp build_queries(uri, client_id, redirect_uri, code_challenge, state, scopes, resources, prompt) do
    queries =
      uri.query
      |> decode_query()
      |> Map.put("client_id", client_id)
      |> Map.put("redirect_uri", redirect_uri)
      |> Map.put("code_challenge", code_challenge)
      |> Map.put("code_challenge_method", "S256")
      |> Map.put("state", state)
      |> Map.put("scope", build_scopes(scopes))
      |> Map.put("response_type", "code")
      |> Map.put("prompt", build_prompt(prompt))

    resources = build_resources(scopes, resources)
    Enum.reduce(resources, queries, fn resource, acc -> Map.put(acc, "resource", resource) end)
  end

  defp decode_query(nil), do: %{}
  defp decode_query(q), do: URI.decode_query(q)

  defp build_scopes(scopes) do
    (scopes ++ @default_scopes)
    |> Enum.uniq()
    |> Enum.join(" ")
  end

  defp build_resources(_scopes, resources) do
    resources
  end

  defp build_prompt(prompt) do
    if prompt == "", do: "consent", else: prompt
  end

  defp parse_url(url) do
    case URI.parse(url) do
      %URI{} = uri -> {:ok, uri}
      error -> {:error, error}
    end
  end

  defp url_unescape(queries) do
    {:ok, URI.encode_query(queries)}
  end
end
