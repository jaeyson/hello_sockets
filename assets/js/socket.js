import { Socket } from "phoenix"

const socket = new Socket("/auth_socket", {
	params: {token: window.authToken}
})

socket.onOpen(() => console.log("authSocket connected"))
socket.connect()

// const recurringChannel = socket.channel("recurring")

// recurringChannel.on("new_token", (payload) => {
// 	console.log("received new auth token", payload)
// })

// recurringChannel.join()

const dupeChannel = socket.channel("dupe")

dupeChannel.on("number", (payload) => {
	console.log("new number received", payload)
})

dupeChannel.join()
