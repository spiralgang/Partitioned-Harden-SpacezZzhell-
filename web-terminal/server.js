const express = require("express");
const { WebSocketServer } = require("ws");
const { spawn } = require("child_process");

const app = express();
app.use(express.static("."));
const server = app.listen(3000, '127.0.0.1', () => console.log("Serving at http://localhost:3000"));

const wss = new WebSocketServer({ server, path: "/terminal" });
wss.on("connection", (ws) => {
  const shell = spawn("/system/bin/sh");
  shell.stdout.on("data", (data) => ws.send(data.toString()));
  shell.stderr.on("data", (data) => ws.send(data.toString()));
  ws.on("message", (msg) => shell.stdin.write(msg));
});
