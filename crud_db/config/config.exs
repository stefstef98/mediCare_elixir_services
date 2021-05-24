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
jwt_validity: 3600
