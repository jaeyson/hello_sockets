# Progress

## Establishing connection

> [!NOTE]
> At page 20

To summarize, a WebSocket connection follows this request flow:
1. Initiate a GET HTTP(S) connection request to the WebSocket endpoint.
2. Receive a 101 or error from the server.
3. Upgrade the protocol to WebSocket if 101 is received.
4. Send/receive frames over the WebSocket connection.

> [!IMPORTANT]
> A connection cannot be upgraded with cURL, so we’ll move back to DevTools for seeing the data exchange.

> [!NOTE]
> reader's perspective
> |
> └──> app.js
>      |
>      └──> user_socket.js
>           |
>           └──> endpoint.ex
>                |
>                └──> user_socket.ex (UserSocket.connect/3)
>                     |
>                     └──> room_channel.ex (RoomChannel.join/3)

## Long polling

> [!NOTE]
> At page 24

Long polling uses a request flow as follows:
1. The client initiates an HTTP request to the server.
2. The server doesn’t respond to the request, instead leaving it open. The
server will respond when it has new data or too much time elapses.
3. The server sends a complete response to the client. At this point the client
is aware of the real-time data from the server.
4. The client loops this flow as long as the real-time communication is
desired.

> [!NOTE]
> The WebSocket protocol provides a strong real-time communication layer for
> our real-time applications. WebSockets start as normal HTTP requests before
> being upgraded to TCP sockets for data exchange.
> At page 26

## Channels vs sockets

> At page 31

Channels are the real-time entry points to our application’s logic and where
most of an application’s request handling code lives. A Channel has several
different responsibilities to enable real-time applications:

- Accept or reject a request to join.
- Handle messages from the client.
- Handle messages from the PubSub.
- Push messages to the client.

The distinction between Channels and Sockets may not be obvious at a glance.
A Socket’s responsibilities involve connection handling and routing of requests
to the correct Channel. A Channel’s responsibilities involve handling requests
from a client and sending data to a client. In this way, a Channel is similar
to a Controller in the MVC (Model-View-Controller) design pattern.


## [Socket fields](https://hexdocs.pm/phoenix/Phoenix.Socket.html#module-socket-fields)

```elixir
%Phoenix.Socket{
  id: "The string id of the socket"
  assigns: "The map of socket assigns, default: `%{}`"
  channel: "The current channel module"
  channel_pid: "The channel pid"
  endpoint: "The endpoint module where this socket originated, for example: `MyAppWeb.Endpoint`"
  handler: "The socket module where this socket originated, for example: `MyAppWeb.UserSocket`"
  joined: "If the socket has effectively joined the channel"
  join_ref: "The ref sent by the client when joining"
  ref: "The latest ref sent by the client"
  pubsub_server: "The registered name of the socket's pubsub server"
  topic: "The string topic, for example `room:123`"
  transport: "An identifier for the transport, used for logging"
  transport_pid: "The pid of the socket's transport process"
  serializer: "The serializer for socket messages"
}
```

## `join` vs `handle_in`

`join/3` (`join(topic, payload, socket)`) is for joining a `topic` or `topic:subtopic` in a channel.

`handle_in/3` (`handle_in(event, payload, socket)`) is to process request after successfully joining a topic.

when a message received, either:

- Reply to the message by returning `{:reply, {:ok, payload}, Phoenix.Socket}`. The payload could be `map() | term() | {:binary, binary()}`.
- Do not reply to the message by returning `{:noreply, Phoenix.Socket}`.
- Disconnect the Channel by returning `{:stop, reason, Phoenix.Socket}`.

## What happens when we send an error?
  
```bash
wscat -c 'ws://localhost:4000/socket/websocket?vsn=2.0.0'
connected (press CTRL+C to quit)
> ["1","1","ping","phx_join",{}]
< ["1","1","ping","phx_reply",{"response":{},"status":"ok"}]

> ["1","2","ping","ping",{}]
< ["1","2","ping","phx_reply",{"response":{"ping":"pong"},"status":"ok"}]

> ["1","2","ping","ping2",{}]
< ["1","1","ping","phx_error",{}]

# Our previously working message will not work until we rejoin the topic
> ["1","2","ping","ping",{}]
< [null,"2","ping","phx_reply",{"response":{"reason":"unmatched topic"},
"status":"error"}]

> ["1","1","ping","phx_join",{}]
< ["1","1","ping","phx_reply",{"response":{},"status":"ok"}]

> ["1","2","ping","ping",{}]
< ["1","2","ping","phx_reply",{"response":{"ping":"pong"},"status":"ok"}]
```

> [!IMPORTANT]
> If we get an error when sending a wrong event, we have to re-join to the topic.

And since only process get error, the rest of channels aren't affected. Thanks to what the OTP brings: fault tolerance. The cool thing here is that a certain channel will not affect the rest of the channels, making the errors for that process isolated.

But since a socket can have lots of channels (since it is not efficient to have 1:1 ratio of socket-channels), when a socket fails, it **will** affect the channels under it. Think of it as parent (socket) and child (channel).

## Phoenix message structure

> At page 39-40

```elixir
# a user joined a topic
# [join ref, msg ref, topic (topic or topic: subtopic),    event,  payload]
[    "1",      "1",           "ping:wild",             "phx_join",      {}]
%Phoenix.Socket{
  assigns: %{},
  channel: HelloSocketsWeb.PingChannel,
  channel_pid: #PID<0.589.0>,
  endpoint: HelloSocketsWeb.Endpoint,
  handler: HelloSocketsWeb.UserSocket,
  id: nil,
  joined: false,
  join_ref: "1",
  private: %{log_handle_in: :debug, log_join: :info},
  pubsub_server: HelloSockets.PubSub,
  ref: nil,
  serializer: Phoenix.Socket.V2.JSONSerializer,
  topic: "ping:wild",
  transport: :websocket,
  transport_pid: #PID<0.581.0>
}

# after joining a topic:subtopic, then issues an "event"
[
  "1",         # join ref
  "2",         # msg ref
  "ping:wild", # topic
  "ping",      # event
  {"ack_phrase": "wit"} # payload
]
%Phoenix.Socket{
  assigns: %{},
  channel: HelloSocketsWeb.PingChannel,
  channel_pid: #PID<0.444.0>,
  endpoint: HelloSocketsWeb.Endpoint,
  handler: HelloSocketsWeb.UserSocket,
  id: nil,
  joined: true,
  join_ref: "1",
  private: %{log_handle_in: :debug, log_join: :info},
  pubsub_server: HelloSockets.PubSub,
  ref: "2",
  serializer: Phoenix.Socket.V2.JSONSerializer,
  topic: "ping:wild",
  transport: :websocket,
  transport_pid: #PID<0.436.0>
}
```

> [!NOTE]
> Some pieces of the message format are optional and can be null depending on the situation. For example, we saw that the ref strings were both null when we used broadcast to send a message to our client. This happens because the information is owned by the client, so the server cannot provide it when pushing data that isn’t in reply to an original message.

## Channel client

Any Channel client has a few key responsibilities that should be followed, in order for all behavior to work as expected:

- Connect to the server and maintain the connection by using a heartbeat.
- Join the requested topics.
- Push messages to a topic and optionally handle responses.
- Receive messages from a topic.
- Handle disconnection and other errors gracefully; try to maintain a connection whenever possible.

> [!WARNING]
> sending a `channel.push("pong")` to the server with the response of `{:noreply, socket}` will receive a **timeout** (after 10s) from client.

## Send message to client

```elixir
HelloSocketsWeb.Endpoint.broadcast("ping", "request_ping", %{})
```

Where `request_ping` is the event name for `handle_out/3` and push via `push(socket, "send_ping", payload)`.

Clients whose the recipient should use `channel.on("send_ping", payload => ...)`.

## Simple authorization

There are two different ways to secure the Channels of
your application—either by authenticating when a client connects to a Socket
or when a client joins a Channel.

### passing auth on every join

```elixir
iex> user_id = 1
1
iex>Phoenix.Token.sign(HelloSocketsWeb.Endpoint,"salt identifier", user_id)
"SFMyNTY.g2gDYQFuBgDIm9cHlwFiAAFRgA.W6IwvEFyxeWVL7o8JDZjsVqXZu_DW3keclDJdOM5AEc"
```

```bash
wscat -c 'ws://localhost:4000/auth_socket/websocket?vsn=2.0.0&token=SF...AEc'
connected (press CTRL+C to quit)
> ["1","1","user:2","phx_join",{}]
< ["1","1","user:2","phx_reply",{"response":
{"reason":"unauthorized"},"status":"error"}]
> ["1","1","user:1","phx_join",{}]
< ["1","1","user:1","phx_reply",{"response":{},"status":"ok"}]
```

> [!INFO]
> this approach is cumbersome, as it sends auth token with each topic join

### pass via socket connection

This task boils down to a few key parts:
-  Controller—generate a token when our page loads and write it into the page's JavaScript
-  JavaScript—send the token parameter with the Socket connection
-  Socket—use the token in our Socket

see:

- page_controller.ex 
- index.html.heex
- js/socket.js

## Cost of sockets vs channels

> [!INFO]
> Each connected Socket adds one connection to the server, but each connected Channel adds zero new connections to the server. Channels do take up a slight amount of memory and CPU because there is a process associated with each, but you can consider Channels nearly free because processes are cheap in Elixir. Sockets are a bit more expensive due to network connections and the heartbeat process.

> [!NOTE]
>  When you are writing a system that has separate real-time features or pages for users and admins, you would add a new Socket. This is because users would not have the ability to connect to admin-specific features and so should be rejected from connecting to the Socket. Separating the Socket authentication like this leads to simpler code further down in the system. You would add to an existing Socket when the authentication needs are the same.
>
> As a general rule of thumb, use multiple Channels with a single Socket. Use multiple Sockets if your application has different authentication needs between different parts of the application. This approach leads to a system architecture with the lowest resource usage.

## Unreliable connections

> [!NOTE]
> At page 68

- A client’s internet connection becomes unstable and drops their connection without any other changes.
- A bug in the client code causes it to close the connection.
- The server restarts due to a routine deploy or operational issue.
















































