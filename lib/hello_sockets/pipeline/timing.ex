defmodule HelloSockets.Pipeline.Timing do
  def unix_ms_now do
    System.os_time(:millisecond)
    # :erlang.system_time(:millisecond)
  end
end
