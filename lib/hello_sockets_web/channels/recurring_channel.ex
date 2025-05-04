defmodule HelloSocketsWeb.RecurringChannel do
  use HelloSocketsWeb, :channel

  @send_after 5_000

  def join(_topic, _channel, socket) do
    schedule_send_token()
    {:ok, socket}
  end

  def handle_info(:send_token, socket) do
    schedule_send_token()
    push(socket, "new_token", %{token: new_token(socket)})
    {:noreply, socket}
  end

  defp new_token(%{assigns: %{user_id: user_id}} = socket) do
    Phoenix.Token.sign(socket, "salt_identifier", user_id)
  end

  defp schedule_send_token do
    Process.send_after(self(), :send_token, @send_after)
  end
end
