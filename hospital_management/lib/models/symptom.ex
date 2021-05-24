defmodule Api.Models.Symptom do
  @db_name Application.get_env(:api_test, :db_db)
  @db_table "symptoms"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  #INFO: mongo also has an internal ID
  #ignored in this exercise
  defstruct [
    :id,
    :name,
    :description,
    :updated_at,
    :created_at
  ]
end
