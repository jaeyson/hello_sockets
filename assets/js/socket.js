import {Socket} from "phoenix"

const socket = new Socket("/socket", {})
const authSocket = new Socket("/auth_socket", {
  params: {token: window.authToken}
})

authSocket.onOpen(_ => console.info("authSocket connected"))
authSocket.connect()

socket.connect()

const channel = socket.channel("ping")

channel.join()
  // .receive("ok", resp => console.info("Joined ping", resp))
  .receive("ok", resp => {
    console.info("Joined ping", resp)

    // channel.push("invalid")
    //   .receive("ok", _ => console.info("won't happen"))
    //   .receive("error", _ => console.error("won't happen yet"))
    //   .receive("timeout", _ => console.warn("pong message timeout (possibly using {:noreply, socket})", resp))

    console.info("send ping")
    channel.push("ping")
      .receive("ok", resp => console.info("receive", resp.ping))

    console.info("push pong")
    channel.push("pong")
      .receive("ok", _ => console.info("won't happen"))
      .receive("error", _ => console.error("won't happen yet"))
      .receive("timeout", resp => console.warn("pong message timeout (possibly using {:noreply, socket})", resp))

    channel.push("param_ping", {error: true})
      .receive("error", resp => console.error("param_ping error:", resp))

    channel.push("param_ping", {error: false, arr: [1,2]})
      .receive("ok", resp => console.info("param_ping ok", resp))
  })
  .receive("error", resp => console.error("Unable to join ping", resp))

channel.on("send_ping", payload => {
  console.info("ping requested", payload)
  channel.push("ping")
    .receive("ok", resp => console.info("ping:", resp.ping))
})

export default socket
