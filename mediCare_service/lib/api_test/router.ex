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


  forward("/bands", to: Api.Endpoint)
  forward("/treatment", to: Endpoints.TreatmentEndpoint)
  forward("/symptom", to: Endpoints.SymptomEndpoint)
  forward("/hospital", to: Endpoints.HospitalEndpoint)

  match _ do
    conn
    |> send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end
end
