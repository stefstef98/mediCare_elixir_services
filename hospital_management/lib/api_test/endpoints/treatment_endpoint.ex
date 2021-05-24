defmodule Endpoints.TreatmentEndpoint do
  use Plug.Router

  alias Api.Views.TreatmentView
  alias Api.Views.SymptomView
  alias Api.Models.Band
  alias Api.Models.Treatment
  alias Api.Models.Symptom
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

  get "/", private: %{view: TreatmentView}  do
    params = Map.get(conn.params, "filter", %{})

    {_, bands} =  Treatment.find(params)

    conn
    |> put_status(200)
    |> assign(:jsonapi, bands)
  end

  post "/", private: %{view: TreatmentView} do
    {disease, drug, id} = {
      Map.get(conn.params, "disease", nil),
      Map.get(conn.params, "drug", nil),
      Map.get(conn.params, "id", nil)
    }

    cond do
      is_nil(disease) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "disease must be present!"})

      is_nil(drug) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "drug must be present!"})

      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "id must be present!"})

      true ->
      case %Treatment{disease: disease, drug: drug, id: id} |> Treatment.save do
        {:ok, createdEntry} ->
          uri = "#{@api_scheme}://#{@api_host}:#{@api_port}#{conn.request_path}/"
          #not optimal

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

  patch "/", private: %{view: TreatmentView} do
    #not tested

    {drug, disease, id} = {
      Map.get(conn.params, "drug", nil),
      Map.get(conn.params, "disease", nil),
      Map.get(conn.params, "id", nil)
    }

    Treatment.delete(id)

    case %Treatment{drug: drug, disease: disease, id: id} |> Treatment.save do
      {:ok, createdEntry} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, createdEntry)
      :error ->
        conn
         |> put_status(500)
         |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
    end
  end

  get "/:id", private: %{view: TreatmentView}  do
    {parsedId, ""} = Integer.parse(id)

    case Treatment.get(parsedId) do
      {:ok, treatment} ->

        conn
        |> put_status(200)
        |> assign(:jsonapi, treatment)

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

    case Treatment.delete(id) do
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
