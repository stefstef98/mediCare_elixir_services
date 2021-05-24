defmodule Api.Views.UserView do
  use JSONAPI.View

  def fields, do: [:name, :password, :created_at, :updated_at]
  def type, do: "user"
  def relationships, do: []
end
