import { Socket } from "phoenix"

const authSocket = new Socket("/auth_socket", {
	params: {token: window.authToken}
})

authToken.onOpen(() => console.log("authSocket connected"))
authToken.connect()