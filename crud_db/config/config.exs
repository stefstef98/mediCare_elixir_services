use Mix.Config

config :api_test,
  db_host: "localhost",
  db_port: 27017,
  db_db: "bands",
  db_tables: [
    "band"
  ],

api_host: "localhost",
api_port: 4000,
api_scheme: "http",
app_secret_key: "secret",
jwt_validity: 3600,

routing_keys: %{
  # User Events
  "user_login" => "api.login.auth-login.events",
  "user_logout" => "api.login.auth-logout.events",
  "user_register" => "api.login.auth-register.events"
},
event_url: "guest:guest@localhost", #username:passwd (here default)
event_exchange: "my-api",
event_queue: "auth-service"
