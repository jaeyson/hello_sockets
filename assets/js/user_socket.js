// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import { Socket } from "phoenix"

// And connect to the path in "lib/hello_sockets_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", { params: { token: window.userToken } })

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/hello_sockets_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/hello_sockets_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/hello_sockets_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic.
// Let's assume you have a channel with a topic named `room` and the
// subtopic is its id - in this case 42:
let channel = socket.channel("ping", {})
channel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp)

    // channel.on("send_ping", payload => {
    //   console.log("ping requested", payload)
    //   channel.push("ping", { ack_phrase: "pong" })
    //     .receive("ok", resp => console.log("ping:", resp))
    // })

    console.log("send ping")
    channel.push("ping", { ack_phrase: "wild" })
      .receive("ok", resp => {
        console.info("receive", resp)
      })
      .receive("error", resp => console.error("Unable to join", resp))
      .receive("timeout", resp => console.error("message timeout", resp))

    // channel.push("param_ping", { error: true })
    //   .receive("error", resp => console.error("param ping error:", resp))

    // channel.push("param_ping", { error: false, arr: [1, 2] })
    //   .receive("error", resp => console.error("param ping ok:", resp))

    // channel.push("invalid")
    //   .receive("ok", _resp => console.log("won't happen"))
    //   .receive("error", _resp => console.log("won't happen"))
    //   .receive("timeout", _resp => console.log("invalid event timeout"))
  })
  .receive("error", resp => console.error("Unable to join", resp))
export default socket
