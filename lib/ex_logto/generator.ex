defmodule ExLogto.Generator do
  @moduledoc """
    some random number, base64 encoding helper functions

    - deprecated :crypto.rand_uniform - replaced with :rand.uniform - needed to do some recursion..
    #for _ <- 1..64, into: "", do: <<Enum.at(symbols, :crypto.rand_uniform(0, symbol_count))>>

  """
  @base 64

  @doc """
    generate the code challenge
  """
  def generate_code_challenge(code_verifier) do
    :sha256
    |> :crypto.hash(code_verifier)
    |> Base.url_encode64(padding: false)
  end

  @doc """
    generate the "state" for the session
  """
  def generate_state, do: generate_code_verifier()

  def generate_code_verifier do
    symbols = ~c"0123456789abcdef"
    symbol_count = Enum.count(symbols)
    for _ <- 1..@base, into: "", do: <<rand_char(symbols, symbol_count)>>
  end

  defp rand_char(symbols, count) do
    case Enum.at(symbols, :rand.uniform(count)) do
      nil -> rand_char(symbols, count)
      result -> result
    end
  end
end
