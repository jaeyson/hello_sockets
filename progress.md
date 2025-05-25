# Progress #

## Establishing connection ##

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
> reader's perspective:
> endpoint -> user_socket.js -> UserSocket.connect/3 -> RoomChannel.join/3

## Long polling ##

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
