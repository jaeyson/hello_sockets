import {Socket} from "phoenix"

const fastSocket = new Socket("/stats_socket", {})
fastSocket.connect()

const fastStatsChannel = fastSocket.channel("valid")
fastStatsChannel.join()

for (let f = 0; f < 5; f++) {
  fastStatsChannel.push("parallel_slow_ping")
    .receive("ok", _ => console.warn("Parallel slow ping response received", f))
}
console.info("5 parallel slow pings requested")

const slowStatsSocket = new Socket("/stats_socket", {})
slowStatsSocket.connect()

const slowStatsChannel = slowStatsSocket.channel("valid")
slowStatsChannel.join()

for (let s = 0; s < 5; s++) {
  slowStatsChannel.push("slow_ping")
    .receive("ok", _ => console.warn("Slow ping response received", s))
}
console.info("5 slow pings requested")

const statsSocket = new Socket("/stats_socket", {})
statsSocket.connect()

const statsChannelInvalid = statsSocket.channel("invalid")
statsChannelInvalid.join()
  .receive("error", _ => statsChannelInvalid.leave())

const statsChannelValid = statsSocket.channel("valid")
statsChannelValid.join()

for (let i = 0; i < 5; i++) {
  statsChannelValid.push("ping")
}

const socket = new Socket("/socket", {})
const authSocket = new Socket("/auth_socket", {
  params: {token: window.authToken}
})

authSocket.onOpen(_ => console.info("authSocket connected"))
authSocket.connect()

socket.connect()

const authUserChannel = authSocket.channel(`user:${window.userId}`)
// authUserChannel.on("push", payload => {
//   console.info("received auth user push", payload)
// })
authUserChannel.on("push_timed", payload => {
  console.info("received timed auth user push", payload)
})

authUserChannel.join()

const recurringChannel = authSocket.channel("recurring")
recurringChannel.on("new_token", payload => {
  console.info("received new auth token:", payload)
})

recurringChannel.join()

const dedupeChannel = socket.channel("dupe")
dedupeChannel.on("number", payload => {
  console.info("dedupe: ", payload)
})

dedupeChannel.join()

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
