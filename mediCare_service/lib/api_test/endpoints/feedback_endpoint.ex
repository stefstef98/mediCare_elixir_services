defmodule Endpoints.FeedbackEndpoint do
  use Plug.Router


  alias Api.Views.FeedbackView
  alias Api.Models.Feedback
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

  get "/feedbacks"  do
    getCategoriesUrl = "http://localhost:3000/feedback"

    case HTTPoison.get(getCategoriesUrl) do
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

  post "/" do

    addUrl = "http://localhost:3000/feedback"

    {rating, text, id} = {
      Map.get(conn.params, "rating", nil),
      Map.get(conn.params, "text", nil),
      Map.get(conn.params, "id", nil)
    }


    body = Poison.encode!( %Feedback{rating: rating, text: text, id: id})

    headers = [{"Content-type", "application/json"}]

    case HTTPoison.post(addUrl, body, headers, []) do
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

  patch "/" do

    updateUrl="http://localhost:3000/feedback"

    {rating, text, id} = {
      Map.get(conn.params, "rating", nil),
      Map.get(conn.params, "text", nil),
      Map.get(conn.params, "id", nil)
    }

    body = Poison.encode!( %Feedback{rating: rating, text: text,  id: id})

    headers = [{"Content-type", "application/json"}]

    case HTTPoison.patch(updateUrl, body, headers, []) do
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

  delete "/" do
    headers = []

    {id} = {
      Map.get(conn.path_params, "id", nil)
    }

    deleteUrl = "http://localhost:3000/feedback"

    case HTTPoison.delete(deleteUrl, headers,[]) do
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
