defmodule HelloSocketsWeb.AuthChannel do
  use HelloSocketsWeb, :channel
  require Logger

  # this is cumbersome, as it sends auth token with each topic join
  # pass via socket connection instead. see progress.md
  # this is only 1 way of authorising token
  def join("user:" <> req_user_id, _payload, %{assigns: %{user_id: user_id}} = socket) do
    if req_user_id == to_string(user_id) do
      {:ok, socket}
    else
      Logger.error("#{__MODULE__} failed #{req_user_id} != #{user_id}")
      {:error, %{reason: "unauthorized"}}
    end
  end
end
