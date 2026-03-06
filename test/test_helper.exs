ExUnit.start()

# Configure Mox and replace the http client used by Core with the mock by default in tests
Mox.defmock(ExLogto.HttpClientMock, for: ExLogto.HttpClientBehaviour)
Application.put_env(:ex_logto, :http_client, ExLogto.HttpClientMock)
