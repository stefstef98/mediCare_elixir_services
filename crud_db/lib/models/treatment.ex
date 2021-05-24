defmodule Api.Models.Treatment do
  @db_name Application.get_env(:api_test, :db_db)
  @db_table "treatments"

  use Api.Models.Base
  #INFO: mongo also has an internal ID
  #ignored in this exercise
  defstruct [
    :id,
    :disease,
    :drug,
    :updated_at,
    :created_at
  ]
end
