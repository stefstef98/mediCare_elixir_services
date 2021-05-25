defmodule Endpoints.SymptomEndpoint do
  use Plug.Router


  alias Api.Views.SymptomView
  alias Api.Models.Symptom
  alias Api.Plugs.JsonTestPlug
  alias Api.Service.Publisher

  @routing_keys Application.get_env(:api_test, :routing_keys)

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

  get "/", private: %{view: SymptomView}  do
    params = Map.get(conn.params, "filter", %{})

    case Symptom.findAll(params) do
      {:ok, symptoms} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, symptoms)
      {:error, []} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, [])
    end
  end

  post "/", private: %{view: SymptomView} do

    {name, description, id} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "description", nil),
      Map.get(conn.params, "id", nil)
    }

    cond do
      is_nil(name) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "name must be present!"})

      is_nil(description) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "description must be present!"})

      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "id must be present!"})

      true ->
      case %Symptom{name: name, description: description, id: id} |> Symptom.save do
        {:ok, createdEntry} ->
          uri = "#{@api_scheme}://#{@api_host}:#{@api_port}#{conn.request_path}/"
          #not optimal

          Publisher.publish(
            @routing_keys |> Map.get("symptom_added"),
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

  patch "/", private: %{view: SymptomView} do
    #not tested

    {name, description, id} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "description", nil),
      Map.get(conn.params, "id", nil)
    }

    Symptom.delete(id)

    case %Symptom{name: name, description: description, id: id} |> Symptom.save do
      {:ok, createdEntry} ->

        Publisher.publish(
            @routing_keys |> Map.get("symptom_updated"),
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

  get "/:id", private: %{view: SymptomView}  do
    {parsedId, ""} = Integer.parse(id)

    case Symptom.get(parsedId) do
      {:ok, symptom} ->

        conn
        |> put_status(200)
        |> assign(:jsonapi, symptom)

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

    case Symptom.delete(id) do
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
