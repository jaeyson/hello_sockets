defmodule Integraton.PipelineTest do
  use HelloSocketsWeb.ChannelCase, async: false

  alias HelloSockets.Pipeline.Producer
  alias HelloSocketsWeb.AuthSocket

  test "event are pushed from beginning to end correctly" do
    connect_auth_socket(1)

    Enum.each(1..10, fn n ->
      Producer.push_timed(%{data: %{n: n}, user_id: 1})
      assert_push "push_timed", %{n: ^n}
    end)
  end

  test "an event is not delivered to the wrong user" do
    connect_auth_socket(2)

    Producer.push_timed(%{data: %{test: true}, user_id: 1})
    refute_push "push_timed", %{test: true}
  end

  test "events are timed on delivery" do
    assert {:ok, _pid} = StatsDLogger.start_link(port: 8127, formatter: :send)
    connect_auth_socket(1)

    Producer.push_timed(%{data: %{test: true}, user_id: 1})
    assert_push "push_timed", %{test: true}
    assert_receive {:statsd_recv, "pipeline.push_delivered", _value}
  end

  defp connect_auth_socket(user_id) do
    {:ok, _reply, %Phoenix.Socket{}} =
      AuthSocket
      |> socket(nil, %{user_id: user_id})
      |> subscribe_and_join("user:#{user_id}", %{})
  end
end
