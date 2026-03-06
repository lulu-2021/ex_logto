defmodule ExLogto.HttpClientBehaviour do
  @moduledoc false

  @callback post(String.t(), any(), list(), keyword()) :: {:ok, any()} | {:error, any()}
end
