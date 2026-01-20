defmodule ExLogto.CoreTest do
  use ExUnit.Case
  import Mox
  alias ExLogto.Core

  setup :verify_on_exit!

  test "fetch_token_by_authorization_code returns decoded map on 200" do
    response_body = ~s({"access_token":"a","refresh_token":"r"})

    ExLogto.HttpClientMock
    |> expect(:post, fn _url, _body, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}}
    end)

    options = %{
      token_endpoint: "https://id.example:8443/token",
      client_id: "cid",
      client_secret: "cs",
      redirect_uri: "https://app/callback",
      code_verifier: "cv",
      code: "thecode"
    }

    assert {:ok, %{"access_token" => "a", "refresh_token" => "r"}} =
             Core.fetch_token_by_authorization_code(options)
  end

  test "fetch_token_by_authorization_code returns error for non-200" do
    ExLogto.HttpClientMock
    |> expect(:post, fn _url, _body, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: 400, body: "bad"}}
    end)

    options = %{
      token_endpoint: "https://id.example:8443/token",
      client_id: "cid",
      redirect_uri: "https://app/callback",
      code_verifier: "cv",
      code: "thecode"
    }

    assert {:error, "HTTP 400: bad"} = Core.fetch_token_by_authorization_code(options)
  end

  test "fetch_token_by_refresh_token returns decoded map on 200" do
    response_body = ~s({"access_token":"new","refresh_token":"r2"})

    ExLogto.HttpClientMock
    |> expect(:post, fn _url, _body, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}}
    end)

    options = %{
      token_endpoint: "https://id.example:8443/token",
      client_id: "cid",
      client_secret: "cs",
      refresh_token: "r1",
      scopes: ["openid"]
    }

    assert {:ok, %{"access_token" => "new", "refresh_token" => "r2"}} =
             Core.fetch_token_by_refresh_token(options)
  end
end
