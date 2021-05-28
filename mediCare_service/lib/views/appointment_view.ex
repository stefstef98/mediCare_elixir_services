defmodule Api.Views.AppointmentView do
  use JSONAPI.View

  def fields, do: [:date, :patient, :doctor, :created_at, :updated_at]
  def type, do: "appointment"
  def relationships, do: []
end
