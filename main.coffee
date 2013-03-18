DEFAULT_PUBLIC_FOLDER_PATH = "./public"
DEFAULT_SERVER_PORT = 8000

# imports
http = require "http"
nodeStatic = require "node-static"
socketIO = require "socket.io"

# set up the static file server
staticServer = new nodeStatic.Server DEFAULT_PUBLIC_FOLDER_PATH
httpServer = http.createServer (request, response) ->
  request.addListener "end", ->
    staticServer.serve request, response


httpServer.listen DEFAULT_SERVER_PORT
