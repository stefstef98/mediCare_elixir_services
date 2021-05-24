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

  post "/register" do
    {name, password, id} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "password", nil),
      Map.get(conn.params, "id", nil)
    }

    cond do
      is_nil(name) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "name must be present!"})

      is_nil(password) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "password must be present!"})

      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "id must be present!"})

      true ->
      case %User{name: name, password: password, id: id} |> User.save do
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


  post "/register2", private: %{view: UserView} do

    {:ok, service} = Api.Service.Auth.start_link

    password_hash = Api.Service.Auth.generate_hash(service, Map.get(conn.params, "password", nil))

    {name, password, id} = {
      Map.get(conn.params, "name", nil),
      password_hash,
      Map.get(conn.params, "id", nil),

    }

    cond do
      is_nil(name) ->
        IO.puts("name missing")
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "name must be present!"})

      is_nil(password) ->
        IO.puts("password missing")
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "password must be present!"})

      is_nil(id) ->
        IO.puts("id missing")
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "id must be present!"})

      User.find(%{name: name}) != :error ->
        conn
        |> put_status(409)
        |> assign(:jsonapi, %{error: "name already exists in the db!"})


      true ->
        case %User{name: name, password: password,id: id} |> User.save do
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
  post "/login" do
   {name, password} = {
     Map.get(conn.params, "name", nil),
     Map.get(conn.params, "password", nil)
   }

   cond do
    is_nil(name) ->
      conn
      |> put_status(400)
      |> assign(:jsonapi, %{error: "name must be present!"})

    is_nil(password) ->
      conn
      |> put_status(400)
      |> assign(:jsonapi, %{error: "password must be present!"})

    true ->

      case User.find(%{name: name}) do
        {:ok, user} ->
          password_hash = user.password
          {:ok, service} = Api.Service.Auth.start_link
          cond do
            !Api.Service.Auth.verify_hash(service, {password, password_hash}) ->
              conn
              |> put_status(403)
              |> assign(:jsonapi, %{error: "password invalid!"})

          true ->
            {:ok, service} = Api.Service.Auth.start_link
            token = Api.Service.Auth.issue_token(service, %{:name => name})

            conn
            |> put_status(200)
            |> assign(:jsonapi, %{:token => token})
          :error ->
            conn
            |> put_status(500)
            |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
          end
        :error ->
          conn
          |> put_status(404)
          |> assign(:jsonapi, %{"error" => "User not found"})
      end
  end
 end

  post "/logout" do
    {name} = {
      Map.get(conn.params, "name", nil)
    }

    {:ok, service} = Api.Service.Auth.start_link

    case Api.Service.Auth.revoke_token(service, %{:name => name}) do
      :ok ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, %{"message" => "logged out: #{name}, token deleted"})
      :error ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"message" => "Could not log out. problem! Please log in."})

    end
  end


  forward("/bands", to: Api.Endpoint)

  match _ do
    conn
    |> send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end
end
