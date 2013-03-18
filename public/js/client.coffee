socket = io.connect("/")

# dummy socket thing to print it out
socket.on "message", (data)->
  console.log data

# for demo purposes
socket.emit "message", "a letter for the server"