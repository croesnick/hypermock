defmodule HyperMockHackneyTest do
  use ExUnit.Case, async: false
  use HyperMock, adapter: HyperMock.Adapter.Hackney

  alias HyperMock.NetConnectNotAllowedError
  alias HyperMock.UnmetExpectationError

  test "Hackney: successful GET request with uri" do
    HyperMock.intercept do
      request = %Request{method:  :get,
                         uri:     "http://api.example.com",
                         headers: [],
                         body:    nil,
                         options: [] }
      response = %Response{status: 200, body: nil, headers: []}

      stub_request request, response

      got_response = :hackney.request(request.method, request.uri)
      #TODO Grab the hackney documentation and find out why the respone
      #     is {:error, :nxdomain}
      assert {:ok, response.status, response.headers} == got_response
    end
  end

  test "Hackney: successful GET request with uri, headers, body, options" do
    HyperMock.intercept do
      request = %Request{method:  :get,
                         uri:     "http://api.example.com",
                         headers: [{"Content-Type", "text/plain"}],
                         body:    "ping",
                         options: [:with_body]}
      response = %Response{status: 200, body: "pong", headers: []}

      stub_request request, response

      got_response = :hackney.request(request.method, request.uri, request.headers, request.body, [:with_body])
      assert {:ok, response.status, response.headers, response.body} == got_response
    end
  end

  test "Hackney: successful HEAD request with uri, headers, body, options" do
    HyperMock.intercept do
      request = %Request{method:  :head,
                         uri:     "http://api.example.com",
                         headers: [],
                         body:    nil,
                         options: nil}
      response = %Response{status: 200, body: nil, headers: []}

      stub_request request, response

      got_response = :hackney.request(request.method, request.uri, request.headers, request.body, request.options)
      assert {:ok, response.status, response.headers} == got_response
    end
  end
end
