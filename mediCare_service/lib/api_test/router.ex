defmodule Api.Router do
  use Plug.Router

  alias Api.Models.User
  alias Api.Views.UserView
  alias Api.Plugs.JsonTestPlug


  @api_port Application.get_env(:api_test, :api_port)
  @api_host Application.get_env(:api_test, :api_host)
  @api_scheme Application.get_env(:api_test, :api_scheme)


  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )
  plug(:dispatch)
  plug JsonTestPlug
  plug :encode_response

  defp encode_response(conn, _) do
    conn
    |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
  end

  post "/login" do

    loginUrl =  'http://localhost:4000/login'

    {name, password, id} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "password", nil),
      Map.get(conn.params, "id", nil)
    }

     body = Poison.encode!(%User{name: name, password: password, id: id})
     headers = [{"Content-type", "application/json"}]

     case HTTPoison.post(loginUrl, body, headers) do
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

  post "/register" do


    loginUrl =  'http://localhost:4000/register2'

    {name, password, id} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "password", nil),
      Map.get(conn.params, "id", nil),

    }

    body = Poison.encode!(%User{name: name, password: password, id: id})
    headers = [{"Content-type", "application/json"}]

    case HTTPoison.post(loginUrl, body, headers) do
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

  post "/login" do

    loginUrl =  'http://localhost:4000/login'

    {name, password, id} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "password", nil),
      Map.get(conn.params, "id", nil)
    }

     body = Poison.encode!(%User{name: name, password: password, id: id})
     headers = [{"Content-type", "application/json"}]

     case HTTPoison.post(loginUrl, body, headers) do
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

  post "/logout" do
    loginUrl =  'http://localhost:4000/logout'

  {name, password, id} = {
    Map.get(conn.params, "name", nil),
    Map.get(conn.params, "password", nil),
    Map.get(conn.params, "id", nil)
  }

    body = Poison.encode!(%User{name: name, password: password, id: id})
    headers = [{"Content-type", "application/json"}]

    case HTTPoison.post(loginUrl, body, headers) do
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

  forward("/bands", to: Api.Endpoint)
  forward("/treatment", to: Endpoints.TreatmentEndpoint)
  forward("/symptom", to: Endpoints.SymptomEndpoint)
  forward("/hospital", to: Endpoints.HospitalEndpoint)
  forward("/feedback", to: Endpoints.FeedbackEndpoint)
  forward("/appointment", to: Endpoints.AppointmentEndpoint)

  match _ do
    conn
    |> send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end
end
