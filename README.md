# HelloSockets

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

```bash
wscat -c 'ws://localhost:4000/socket/websocket?vsn=2.0.0'
```

## Phoenix Message Structure

> At page 39

Phoenix Channels use a simple message protocol to represent all messages to and from a client. The contents of the Message allow clients to keep track of the request and reply flow, which is important because multiple asynchronous requests can be issued to a single Channel.

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

### `Phoenix.Message` fields

Let’s break down each of these fields and their use in the Channel flow:

- `Join Ref`: A unique string that matches what the client provided when it connected to the Channel. This helps prevent duplicate Channel subscriptions from the client. In practice, this is a number that is incremented each time a Channel is joined.
- `Message Ref`: A unique string provided by the client on every message. This allows a reply to be sent in response to a client message. In practice, this is a number which is incremented each time a client sends a message.
- `Topic`: The topic of the Channel.
- `Event`: A string identifying the message. The Channel implementation can use pattern matching to handle different events easily.
- `Payload`: A JSON encoded map (string) that contains the data contents of the message. The Channel implementation can use pattern matching on the decoded map to handle different cases for an event.

## `StatsD` not working

### problem

`Statix` library isn't compatible with newer OTP versions

```bash
iex(1)> HelloSockets.Statix.increment("test", 1)
[error] HelloSockets.Statix counter metric "test" lost value 1 due to port closure
{:error, :port_closed}
```

- [Reddit](https://www.reddit.com/r/elixir/comments/1i9jvhg/help_with_statix_library_port_closed_error_when/?rdt=64795)
- [Github thread](https://github.com/lexmag/statix/pull/72)

### solution

Might as well use a [fork version](https://github.com/knocklabs/statix):

```elixir
defp deps do
  [
    ...
    {:statix, git: "git@github.com:knocklabs/statix.git"},
    ...
  ]
end
```

And also, don't forget to run a statsd container.
