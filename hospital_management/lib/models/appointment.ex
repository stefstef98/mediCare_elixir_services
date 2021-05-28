defmodule Api.Models.Appointment do
  @db_name Application.get_env(:api_test, :db_db)
  @db_table "appointments"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  #INFO: mongo also has an internal ID
  #ignored in this exercise
  defstruct [
    :id,
    :date,
    :patient,
    :doctor,
    :updated_at,
    :created_at
  ]
end
