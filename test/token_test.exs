defmodule ExLogto.TokenTest do
  use ExUnit.Case
  alias ExLogto.Token

  test "decode_token parses a JSON string and returns {:ok, map}" do
    json = ~s({"sub":"123","name":"alice"})
    assert {:ok, %{"sub" => "123", "name" => "alice"}} = Token.decode_token(json)
  end
end
