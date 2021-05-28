defmodule Endpoints.AppointmentEndpoint do
  use Plug.Router


  alias Api.Views.AppointmentView
  alias Api.Models.Appointment
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

  get "/", private: %{view: AppointmentView}  do

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

              case Appointment.findAll(params) do
                {:ok, appointments} ->
                  conn
                  |> put_status(200)
                  |> assign(:jsonapi, appointments)
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
            end
        end
    end
  end

  post "/", private: %{view: AppointmentView} do

    {date, patient, doctor, id} = {
      Map.get(conn.params, "date", nil),
      Map.get(conn.params, "patient", nil),
      Map.get(conn.params, "doctor", nil),
      Map.get(conn.params, "id", nil)
    }

    cond do
      is_nil(date) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "date must be present!"})

      is_nil(patient) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "patient must be present!"})

      is_nil(doctor) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "doctor must be present!"})

      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "id must be present!"})

      true ->
      case %Appointment{date: date, patient: patient, doctor: doctor, id: id} |> Appointment.save do
        {:ok, createdEntry} ->
          uri = "#{@api_scheme}://#{@api_host}:#{@api_port}#{conn.request_path}/"
          #not optimal

          Publisher.publish(
            @routing_keys |> Map.get("appointment_added"),
            %{:doctor => doctor})

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

  patch "/", private: %{view: AppointmentView} do
    #not tested

    {date, patient, doctor, id} = {
      Map.get(conn.params, "date", nil),
      Map.get(conn.params, "patient", nil),
      Map.get(conn.params, "doctor", nil),
      Map.get(conn.params, "id", nil)
    }

    Appointment.delete(id)

    case %Appointment{date: date, patient: patient, doctor: doctor, id: id} |> Appointment.save do
      {:ok, createdEntry} ->

        Publisher.publish(
          @routing_keys |> Map.get("appointment_updated"),
          %{:doctor => doctor})

        conn
        |> put_status(200)
        |> assign(:jsonapi, createdEntry)
      :error ->
        conn
         |> put_status(500)
         |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
    end
  end

  get "/:id", private: %{view: AppointmentView}  do
    {parsedId, ""} = Integer.parse(id)

    case Appointment.get(parsedId) do
      {:ok, appointment} ->

        conn
        |> put_status(200)
        |> assign(:jsonapi, appointment)

      :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{"error" => "'treatment' not found"})
    end
  end

  delete "/" do

    {id} = {
      Map.get(conn.params, "id", nil)
    }

    case Appointment.delete(id) do
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
