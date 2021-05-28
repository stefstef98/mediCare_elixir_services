use Mix.Config

config :api_test,
  db_host: "localhost",
  db_port: 27017,
  db_db: "bands",
  db_tables: [
    "band"
  ],

api_host: "localhost",
api_port: 3000,
api_scheme: "http",
app_secret_key: "secret",
jwt_validity: 3600,

routing_keys: %{
  # User Events
  "symptom_added" => "api.resource.symptom-add.events",
  "symptom_updated" => "api.resource.symptom-update.events",
  "hospital_added" => "api.resource.hospital-add.events",
  "hospital_updated" => "api.resource.hospital-update.events",
  "treatment_added" => "api.resource.treatment-add.events",
  "treatment_updated" => "api.resource.treatment-update.events",
  "feedback_added" => "api.resource.feedback-add.events",
  "feedback_updated" => "api.resource.feedback-updated.events",
  "appointment_added" => "api.resource.appointment-add.events",
  "appointment_updated" => "api.resource.appointment-updated.events"
},
event_url: "guest:guest@localhost", #username:passwd (here default)
event_exchange: "my-api",
event_queue: "resource-service"
