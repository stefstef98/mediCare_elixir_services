defmodule Api.Endpoint do
  use Plug.Router


  alias Api.Views.BandView
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
  plug Api.AuthPlug
  plug :encode_response


  defp encode_response(conn, _) do
    conn
    |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
  end

  get "/", private: %{view: BandView}  do
    params = Map.get(conn.params, "filter", %{})

    {_, bands} =  Band.find(params)

    conn
    |> put_status(200)
    |> assign(:jsonapi, bands)
  end



  delete "/:id" do
    {parsedId, ""} = Integer.parse(id)

    case Band.delete(parsedId) do
      :error ->
         conn
         |> put_status(404)
         |> assign(:jsonapi, %{"error" => "'band' not found"})
      :ok ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, %{message: "#{id} was deleted"})
    end

  end

  patch "/:id", private: %{view: BandView} do
    #not tested
    {parsedId, ""} = Integer.parse(id)

    {name, year} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "year", nil)
    }

    Band.delete(parsedId)

    case %Band{name: name, year: year, id: parsedId} |> Band.save do
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

  post "/", private: %{view: BandView} do
    {name, year, id} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "year", nil),
      Map.get(conn.params, "id", nil)
    }

    cond do
      is_nil(name) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "name must be present!"})

      is_nil(year) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "year must be present!"})

      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "id must be present!"})

      true ->
      case %Band{name: name, year: year, id: id} |> Band.save do
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

  get "/treatment/:id", private: %{view: TreatmentView}  do
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

  post "/treatment", private: %{view: TreatmentView} do
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

  get "/symptom/:id", private: %{view: SymptomView}  do
    {parsedId, ""} = Integer.parse(id)

    case Symptom.get(parsedId) do
      {:ok, symptom} ->

        conn
        |> put_status(200)
        |> assign(:jsonapi, symptom)

      :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{"error" => "'symptom' not found"})
    end
  end

  post "/symptom", private: %{view: SymptomView} do
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

end
