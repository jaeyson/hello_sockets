defmodule HelloSockets do
  @moduledoc """
  HelloSockets keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def request_ping(event, payload) do
    HelloSocketsWeb.Endpoint.broadcast("ping", event, payload)
  end
end
