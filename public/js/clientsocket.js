// Generated by CoffeeScript 1.6.2
var socket;

socket = io.connect("/");

socket.on("message", function(data) {
  return console.log(data);
});

socket.emit("message", "a letter for the server");
