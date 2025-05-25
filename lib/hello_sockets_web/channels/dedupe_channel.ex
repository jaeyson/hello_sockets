defmodule HelloSocketsWeb.DedupeChannel do
  use HelloSocketsWeb, :channel

  intercept ["number"]

  def join(_topic, _channel, socket) do
    {:ok, socket}
  end

  def handle_out("number", %{number: number}, socket) do
    buffer = Map.get(socket.assigns, :buffer, [])
    next_buffer = [number | buffer]
    dbg(next_buffer)

    socket =
      socket
      |> assign(:buffer, next_buffer)
      |> enqueue_send_buffer()

    {:noreply, socket}
  end

  def handle_info(:send_buffer, %{assigns: %{buffer: buffer}} = socket) do
    buffer
    |> Enum.reverse()
    |> Enum.uniq()
    |> Enum.each(&push(socket, "number", %{value: &1}))

    socket =
      socket
      |> assign(:buffer, [])
      |> assign(:awaiting_buffer?, false)

    {:noreply, socket}
  end

  def broadcast(numbers, times) do
    Enum.each(1..times, fn _ ->
      Enum.each(numbers, fn number ->
        HelloSocketsWeb.Endpoint.broadcast!("dupe", "number", %{number: number})
      end)
    end)
  end

  defp enqueue_send_buffer(%{assigns: %{awaiting_buffer?: true}} = socket) do
    socket
  end

  defp enqueue_send_buffer(socket) do
    Process.send_after(self(), :send_buffer, :timer.seconds(1))
    assign(socket, :awaiting_buffer?, true)
  end
end
