defmodule HelloSocketsWeb.WildcardChannel do
  use HelloSocketsWeb, :channel

  def join("wild:" <> numbers, _payload, socket) do
    case numbers_correct?(numbers) do
      true ->
        {:ok, socket}

      false ->
        {:error, %{}}
    end
  end

  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, "pong"}, socket}
  end

  defp numbers_correct?(numbers) do
    numbers
    |> String.split(":")
    |> Enum.map(fn n ->
      case Integer.parse(n) do
        {int, _} ->
          int

        :error ->
          :error
      end
    end)
    |> case do
      [a, b] when b == a * 2 ->
        true

      _ ->
        false
    end
  end
end
