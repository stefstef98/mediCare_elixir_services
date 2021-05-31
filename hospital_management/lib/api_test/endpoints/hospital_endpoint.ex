defmodule Endpoints.HospitalEndpoint do
  use Plug.Router


  alias Api.Views.HospitalView
  alias Api.Models.Hospital
  alias Api.Models.JwtToken
  alias Api.Plugs.JsonTestPlug
  alias Api.Service.Publisher

  @routing_keys Application.get_env(:api_test, :routing_keys)


  @api_port Application.get_env(:api_test, :api_port)
  @api_host Application.get_env(:api_test, :api_host)
  @api_scheme Application.get_env(:api_test, :api_scheme)
  @token_verification 'http://localhost:4000/tokeninfo'

  plug :match
  plug :dispatch
  plug JsonTestPlug
  plug :encode_response


  defp encode_response(conn, _) do
    conn
    |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
  end

  get "/", private: %{view: HospitalView}  do
    headers = get_req_header(conn, "authorization")
    header = [{"Content-type", "application/json"}]
    case headers do
      ["Bearer " <> token] ->
        body = Poison.encode!(%JwtToken{jwt: token})
        case HTTPoison.post(@token_verification, body, header) do
          {_, response} ->
            cond do
              response.status_code == 200 ->

              params = Map.get(conn.params, "filter", %{})

              case Hospital.findAll(params) do
                {:ok, hospitals} ->
                  conn
                  |> put_status(200)
                  |> assign(:jsonapi, hospitals)
                {:error, []} ->
                  conn
                  |> put_status(200)
                  |> assign(:jsonapi, [])
              end
              response.status_code == 400 -> conn
                                             |> put_status(400)
                                             |> assign(
                                                  :jsonapi,
                                                  %{body: "Token is invalid!"}
                                                )
              true ->
                conn
                |> put_status(500)
                |> assign(:jsonapi, %{body: "Unexpected error, invalid response from tokeninfo", code: response.status_code})
            end
        end
    end
  end

  post "/", private: %{view: HospitalView} do
    {name, specialization, city, available_beds, id} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "specialization", nil),
      Map.get(conn.params, "city", nil),
      Map.get(conn.params, "available_beds", nil),
      Map.get(conn.params, "id", nil)
    }

    cond do
      is_nil(name) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "name must be present!"})

      is_nil(specialization) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "specialization must be present!"})

      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "id must be present!"})

      true ->
      case %Hospital{name: name, specialization: specialization, city: city, available_beds: available_beds, id: id} |> Hospital.save do
        {:ok, createdEntry} ->
          uri = "#{@api_scheme}://#{@api_host}:#{@api_port}#{conn.request_path}/"
          #not optimal

          Publisher.publish(
            @routing_keys |> Map.get("hospital_added"),
            %{:name => name})

          conn
          |> put_resp_header("location", "#{uri}#{id}")
          |> put_status(201)
          |> assign(:jsonapi, createdEntry)
        :error ->
          conn
           |> put_status(500)
           |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
      end
    end
  end

  patch "/", private: %{view: HospitalView} do
    #not tested

    {name, specialization, city, available_beds, id} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "specialization", nil),
      Map.get(conn.params, "city", nil),
      Map.get(conn.params, "available_beds", nil),
      Map.get(conn.params, "id", nil)
    }

    Hospital.delete(id)

    case %Hospital{name: name, specialization: specialization, city: city, available_beds: available_beds, id: id} |> Symptom.save do
      {:ok, createdEntry} ->

        Publisher.publish(
          @routing_keys |> Map.get("hospital_updated"),
          %{:name => name})

        conn
        |> put_status(200)
        |> assign(:jsonapi, createdEntry)
      :error ->
        conn
         |> put_status(500)
         |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
    end
  end

  get "/:id", private: %{view: HospitalView}  do
    {parsedId, ""} = Integer.parse(id)

    case Hospital.get(parsedId) do
      {:ok, hospital} ->

        conn
        |> put_status(200)
        |> assign(:jsonapi, hospital)

      :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{"error" => "'treatment' not found"})
    end
  end

  delete "/" do

    {parsedId} = {

      Map.get(conn.params, "id", nil)

    }

    case Hospital.delete(parsedId) do
      :error ->
         conn
         |> put_status(404)
         |> assign(:jsonapi, %{"error" => "'band' not found"})
      :ok ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, %{message: " was deleted"})
    end
  end
end
