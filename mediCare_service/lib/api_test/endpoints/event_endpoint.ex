defmodule Endpoints.EventEndpoint do
    use Plug.Router
  
    alias Api.Plugs.JsonTestPlug
  
    @api_port Application.get_env(:api_test, :api_port)
    @api_host Application.get_env(:api_test, :api_host)
    @api_scheme Application.get_env(:api_test, :api_scheme)
  
    plug :match
    plug :dispatch
    plug JsonTestPlug
    plug :encode_response
  
  
    defp encode_response(conn, _) do
      conn
      |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
    end
  
    get "/"  do
      getCategoriesUrl = "http://localhost:4343/events"
  
      auth = get_req_header(conn, "authorization")
      headers = [{"Authorization","#{auth}"}]
  
      case HTTPoison.get(getCategoriesUrl, headers) do
          {:ok, response} ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(200, response.body)
          {:not_found, response} ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(404, response.body)
          {:error, response} ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(500, response.body)
      end
    end
end  