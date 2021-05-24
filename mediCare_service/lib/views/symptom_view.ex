defmodule Api.Views.SymptomView do
  use JSONAPI.View

  def fields, do: [:name, :description, :created_at, :updated_at]
  def type, do: "symptom"
  def relationships, do: []
end
