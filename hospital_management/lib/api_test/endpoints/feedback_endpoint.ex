defmodule Endpoints.FeedbackEndpoint do
  use Plug.Router


  alias Api.Views.FeedbackView
  alias Api.Models.Feedback
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

  get "/", private: %{view: FeedbackView}  do
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

              case Feedback.findAll(params) do
                {:ok, feedbacks} ->
                  conn
                  |> put_status(200)
                  |> assign(:jsonapi, feedbacks)
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

  post "/", private: %{view: FeedbackView} do

    {rating, text, id} = {
      Map.get(conn.params, "rating", nil),
      Map.get(conn.params, "text", nil),
      Map.get(conn.params, "id", nil)
    }

    cond do
      is_nil(rating) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "rating must be present!"})

      is_nil(text) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "text must be present!"})

      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "id must be present!"})

      true ->
      case %Feedback{rating: rating, text: text, id: id} |> Feedback.save do
        {:ok, createdEntry} ->
          uri = "#{@api_scheme}://#{@api_host}:#{@api_port}#{conn.request_path}/"
          #not optimal

          Publisher.publish(
            @routing_keys |> Map.get("feedback_added"),
            %{:text => text})

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

  patch "/", private: %{view: FeedbackView} do
    #not tested

    {rating, text, id} = {
      Map.get(conn.params, "rating", nil),
      Map.get(conn.params, "text", nil),
      Map.get(conn.params, "id", nil)
    }

    Feedback.delete(id)

    case %Feedback{rating: rating, text: text, id: id} |> Feedback.save do
      {:ok, createdEntry} ->

        Publisher.publish(
          @routing_keys |> Map.get("feedback_updated"),
          %{:text => text})

        conn
        |> put_status(200)
        |> assign(:jsonapi, createdEntry)
      :error ->
        conn
         |> put_status(500)
         |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
    end
  end

  get "/:id", private: %{view: FeedbackView}  do
    {parsedId, ""} = Integer.parse(id)

    case Feedback.get(parsedId) do
      {:ok, feedback} ->

        conn
        |> put_status(200)
        |> assign(:jsonapi, feedback)

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

    case Feedback.delete(id) do
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
