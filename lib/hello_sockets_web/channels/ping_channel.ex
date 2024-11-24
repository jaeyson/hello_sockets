defmodule HelloSocketsWeb.PingChannel do
  use HelloSocketsWeb, :channel
  intercept ["request_ping"]

  @impl true
  def join(_topic, _payload, socket) do
    {:ok, socket}
  end

  # @impl true
  # def join("ping:lobby", payload, socket) do
  #   if authorized?(payload) do
  #     {:ok, socket}
  #   else
  #     {:error, %{reason: "unauthorized"}}
  #   end
  # end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # @impl true
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  @impl true
  def handle_in("ping", %{"ack_phrase" => ack_phrase}, socket) do
    {:reply, {:ok, %{ack_phrase: ack_phrase}}, socket}
  end

  @impl true
  def handle_in("ping:" <> phrase, _payload, socket) do
    {:reply, {:ok, %{ping: phrase}}, socket}
  end

  @impl true
  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{ping: "blank"}}, socket}
  end

  @impl true
  # We only handle ping
  def handle_in("pong", _payload, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_in("param_ping", %{"error" => true}, socket) do
    {:reply, {:error, %{reason: "you asked for this!"}}, socket}
  end

  @impl true
  def handle_in("param_ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("ding", _payload, socket) do
    {:stop, :shutdown, {:ok, %{msg: "shutting down"}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (ping:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_out("request_ping", payload, socket) do
    payload = Map.put(payload, "from_node", Node.self())
    push(socket, "send_ping", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
