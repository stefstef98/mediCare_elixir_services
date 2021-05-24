defmodule Api.Views.HospitalView do
  use JSONAPI.View

  def fields, do: [:name, :specialization, :city, :available_beds, :created_at, :updated_at]
  def type, do: "hospital"
  def relationships, do: []
end
