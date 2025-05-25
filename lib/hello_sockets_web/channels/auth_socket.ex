defmodule HelloSocketsWeb.AuthSocket do
  use Phoenix.Socket
  require Logger

  channel "ping", HelloSocketsWeb.PingChannel
  channel "tracker", HelloSocketsWeb.TrackedChannel
  channel "user:*", HelloSocketsWeb.AuthChannel

  @one_day :timer.hours(24)

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case verify(socket, token) do
      {:ok, user_id} ->
        socket = assign(socket, :user_id, user_id)
        {:ok, socket}

      {:error, error} ->
        Logger.error("#{__MODULE__} connect error #{inspect(error)}")
        :error
    end
  end

  @impl true
  def connect(_params, _socket, _connect_info) do
    Logger.error("#{__MODULE__} connect error missing params")
    :error
  end

  @impl true
  def id(%{assigns: %{user_id: user_id}}) do
    "auth_socket:#{user_id}"
  end

  defp verify(socket, token) do
    Phoenix.Token.verify(socket, "salt identifier", token, max_age: @one_day)
  end
end
