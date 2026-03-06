defmodule ExLogto.GeneratorTest do
  use ExUnit.Case
  alias ExLogto.Generator

  test "generate_code_challenge is deterministic and matches sha256+base64url" do
    verifier = "my_code_verifier_123"

    expected =
      :crypto.hash(:sha256, verifier)
      |> Base.url_encode64(padding: false)

    assert Generator.generate_code_challenge(verifier) == expected
    # deterministic: same input => same output
    assert Generator.generate_code_challenge(verifier) ==
             Generator.generate_code_challenge(verifier)
  end

  test "generate_code_verifier produces a 64-character lowercase-hex string" do
    verifier = Generator.generate_code_verifier()
    assert is_binary(verifier)
    assert String.length(verifier) == 64
    assert verifier =~ ~r/^[0-9a-f]+$/
  end

  test "generate_state delegates to generate_code_verifier (returns 64-char string)" do
    state = Generator.generate_state()
    assert is_binary(state)
    assert String.length(state) == 64
  end
end
