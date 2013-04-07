DEFAULT_PUBLIC_FOLDER_PATH = "./public"
DEFAULT_SERVER_PORT = 8000

http = require "http"
nodeStatic = require "node-static"
socketIO = require "socket.io"

# set up the static file server
fileServer = new nodeStatic.Server DEFAULT_PUBLIC_FOLDER_PATH, {cache: false}
httpServer = http.createServer (request, response) ->
  request.addListener "data", ->
    # bug with node.js requires the listener for data to be defined
  request.addListener "end", ->
    fileServer.serve request, response

# set up the dynamic server messaing
io = socketIO.listen httpServer
io.sockets.on 'connection', (socket)->
  socket.emit 'message', 'awaiting token'
  socket.on 'message', (msg)->
    swing = JSON.parse(msg)
    

httpServer.listen DEFAULT_SERVER_PORT
console.log 'Server running at port: ' + DEFAULT_SERVER_PORT