defmodule Api.Views.FeedbackView do
  use JSONAPI.View

  def fields, do: [:rating, :text, :created_at, :updated_at]
  def type, do: "feedback"
  def relationships, do: []
end
