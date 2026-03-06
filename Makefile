
elixir/build:
	MIX_ENV=dev mix deps.get && mix compile

elixir/test:
	MIX_ENV=test mix deps.get && mix test

