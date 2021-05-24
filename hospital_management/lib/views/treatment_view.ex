defmodule Api.Views.TreatmentView do
  use JSONAPI.View

  def fields, do: [:disease, :drug, :created_at, :updated_at]
  def type, do: "treatment"
  def relationships, do: []
end
