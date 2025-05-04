defmodule HelloSocketsWeb.WildcardChannel do
  use HelloSocketsWeb, :channel

  @impl true
  def join("wild:" <> numbers, _payload, socket) do
    if numbers_correct?(numbers) do
      {:ok, socket}
    else
      {:error, %{}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (wildcard:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  defp numbers_correct?(numbers) do
    numbers
    |> String.split(":")
    |> Enum.map(&Integer.parse/1)
    |> Enum.filter(&(&1 !== :error))
    |> case do
      [{a, _}, {b, _}] when b == a * 2 -> true
      _ -> false
    end
  end

  # Add authorization logic here as required.
  # defp authorized?(_payload) do
  #   true
  # end
end
