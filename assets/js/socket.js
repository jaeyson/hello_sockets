import { Socket } from "phoenix";

const statsSocket = new Socket("/stats_socket", {});
statsSocket.connect();

const statsChannelInvalid = statsSocket.channel("invalid");
statsChannelInvalid.join().receive("error", () => statsChannelInvalid.leave());

const statsChannelValid = statsSocket.channel("valid");
statsChannelValid.join();

for (let i = 0; i < 5; i++) {
  statsChannelValid.push("ping");
}

const slowStatsSocket = new Socket("/stats_socket", {});
slowStatsSocket.connect();

const slowStatsChannel = slowStatsSocket.channel("valid");
slowStatsChannel.join();

for (let i = 0; i < 5; i++) {
  slowStatsChannel
    .push("slow_ping")
    .receive("ok", () => console.log("slow ping response received", i));
}
console.log("5 slow pings requested");

const socket = new Socket("/auth_socket", {
  params: { token: window.authToken },
});

socket.onOpen(() => console.log("authSocket connected"));
socket.connect();

const dupeChannel = socket.channel("dupe");
const recurringChannel = socket.channel("recurring");

recurringChannel.on("new_token", (payload) => {
  console.log("received new auth token", payload);
});

dupeChannel.on("number", (payload) => {
  console.log("new number received", payload);
});

dupeChannel.join();
recurringChannel.join();
