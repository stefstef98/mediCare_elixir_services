defmodule Api.Models.Feedback do
  @db_name Application.get_env(:api_test, :db_db)
  @db_table "feedbacks"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  #INFO: mongo also has an internal ID
  #ignored in this exercise
  defstruct [
    :id,
    :rating,
    :text,
    :updated_at,
    :created_at
  ]
end
