# -------------------------------------------------------------------------------------------------
# Constants and Imports
# -------------------------------------------------------------------------------------------------
DEFAULT_PUBLIC_FOLDER_PATH = "./public"
DEFAULT_SERVER_PORT = 8000
http = require "http"
nodeStatic = require "node-static"
socketIO = require "socket.io"

# -------------------------------------------------------------------------------------------------
# Server state
# -------------------------------------------------------------------------------------------------
tokenToPlayerSockets = {}
socketToToken = {}

# -------------------------------------------------------------------------------------------------
# static file server
# -------------------------------------------------------------------------------------------------
fileServer = new nodeStatic.Server DEFAULT_PUBLIC_FOLDER_PATH, {cache: false}
httpServer = http.createServer (request, response) ->
  request.addListener "data", -> # bug with node.js requires the data listener to be defined
  request.addListener "end", -> fileServer.serve request, response

# -------------------------------------------------------------------------------------------------
# dynamic server messaging
# -------------------------------------------------------------------------------------------------
io = socketIO.listen httpServer
io.sockets.on 'connection', (socket)->
  
  # when a any client joins it requests the server time
  # it also includes the timestamp of the original client request
  # this is included in the reply to allow the client to calculate the time delta
  # and compensate for round trip latency
  socket.on "getServerTime", (clientTime)->
    console.log "socketEvent: getServerTime, clientTime: " + clientTime
    socket.emit "serverTime", new Date().getTime(), clientTime

  # when a desktop joins
  # it tells the server what room it wants to listen to updates from
  socket.on 'joinRoom', (token)->
    console.log "socketEvent: joinRoom, token: " + token
    socket.join(token)
    socket.emit('message', 'joining: ' + token)

  # when a mobile phone joins, it tells the server its desired game token
  # and its current timestamp
  # the server replies assigning it a player ID for that game
  # and a delta for its timestamp
  socket.on 'newPlayer', (token, timestamp) ->
    console.log "socketEvent: newPlayer, token: " + token

    tokenToPlayerSockets[token] ?= [null, null]

    # find the first empty space or null if not 
    foundSpace = false
    for existingSocketId, index in tokenToPlayerSockets[token]
      if !existingSocketId?
        playerId = index
        tokenToPlayerSockets[token][playerId] = socket.id
        socketToToken[socket.id] = token
        socket.emit 'playerId', playerId
        socket.emit 'message', "welcome, player " + playerId
        foundSpace = true
        break 

    socket.emit('message', "too many players") unless foundSpace

  # received a swing from a mobile phone
  # broadcast that to all the matching servers
  socket.on 'swing', (swing)->
    console.log "socketEvent: swing, swing: " + swing
    io.sockets.in(socketToToken[socket.id]).emit('swing', swing)
  
  # socket connection closed
  # if its a mobile - remove them as a player
  socket.on 'disconnect', ->
    console.log "socketEvent: disconnect"
    token = socketToToken[socket.id]
    if token?
      for i in [0...tokenToPlayerSockets[token].length]
        if tokenToPlayerSockets[token][i] == socket.id
          tokenToPlayerSockets[token][i] = null # set to null - an empty spot
      delete socketToToken[socket.id]

# -------------------------------------------------------------------------------------------------
# run the damn thing
# -------------------------------------------------------------------------------------------------
httpServer.listen DEFAULT_SERVER_PORT
console.log 'Server running at port: ' + DEFAULT_SERVER_PORT