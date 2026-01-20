defmodule ExLogto.ClientConfigTest do
  use ExUnit.Case
  alias ExLogto.ClientConfig

  setup do
    prev = Application.get_env(:ex_logto, :ex_logto_options)

    opts = %{
      client_id: "cid",
      client_secret: "cs",
      id_server_base: "https://id.example",
      id_server_port: 8443,
      authorization_endpoint: "/auth",
      token_endpoint: "/token",
      end_session_endpoint: "/logout",
      user_info_endpoint: "/userinfo",
      callback_url: "https://app/callback",
      post_logout_redirect_url: "https://app/logout",
      scopes: ["openid"],
      resources: [],
      prompt: "consent"
    }

    Application.put_env(:ex_logto, :ex_logto_options, opts)

    on_exit(fn ->
      if prev != nil do
        Application.put_env(:ex_logto, :ex_logto_options, prev)
      else
        Application.delete_env(:ex_logto, :ex_logto_options)
      end
    end)

    {:ok, opts: opts}
  end

  test "signin_options returns expected fields and builds authorization_endpoint", %{opts: opts} do
    code_challenge = "challenge"
    state = "s1"
    redirect_uri = opts.callback_url

    signin = ClientConfig.signin_options(code_challenge, state, redirect_uri)

    assert signin[:code_challenge] == code_challenge
    assert signin[:client_id] == opts.client_id
    assert signin[:redirect_uri] == redirect_uri
    assert signin[:state] == state
    assert signin[:scopes] == opts.scopes
    assert signin[:resources] == opts.resources
    assert signin[:prompt] == opts.prompt

    expected_auth_endpoint =
      "#{opts.id_server_base}:#{opts.id_server_port}#{opts.authorization_endpoint}"

    assert signin[:authorization_endpoint] == expected_auth_endpoint
  end
end
