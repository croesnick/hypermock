defmodule HyperMock.Adapter.Hackney do
  alias HyperMock.Request
  alias HyperMock.Registry
  alias HyperMock.NetConnectNotAllowedError

  def target_module, do: :hackney

  def request_functions do
    [ {:request, &implementation([&1,&2,&3,&4,&5])} ]
  end

  def implementation(args) do
    request = request_for(args) |> Registry.get()

    if request do
      request |> Tuple.to_list |> Enum.fetch!(1) |> to_response
      #response = request |> Tuple.to_list |> Enum.fetch!(1)
      #process(request, response)
    else
      raise NetConnectNotAllowedError, request_for(args)
    end
  end

  defp request_for([method, uri, headers, body, opts]) do
    %Request{method: method, uri: uri, headers: headers, body: body, options: opts}
  end

  defp normalize_headers(header_list) do
    header_list |> Enum.map(fn({header, value}) -> { List.to_atom(header), to_string(value) } end)
  end

  defp denormalize_headers(header_list) do
    header_list |> Enum.map(fn({header, value}) -> { to_char_list(header), to_char_list(value) } end)
  end

  defp to_response(response) do
    { :ok, response.status, denormalize_headers(response.headers), response.body }
  end
end
