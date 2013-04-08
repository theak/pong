# Handles all server communications
# abstracts away from socket.io to expose simple interface
clientSocket = do ->

  # -----------------------------------------------------------------------------------------------
  # local connection state
  # -----------------------------------------------------------------------------------------------
  socket = io.connect("/")
  timeDelta = null # time difference between client and server
  playerId = null

  # generate the a token if necessary
  token = window.location.hash.slice(1)
  if token.length is 0
    token = makeToken()
    window.location.hash = token

  class SwingMessage
    constructor: (@playerId, @timestamp, @token) ->

  # -----------------------------------------------------------------------------------------------
  # socket event handlers
  # -----------------------------------------------------------------------------------------------
  # on connection to server inform them what room to be joined
  socket.on "connect", ->
    socket.emit "getServerTime", new Date().getTime()
    socket.emit 'joinRoom', token

  # received a swing event from the server - propagate to all receivers
  socket.on "swing", (swingMessage)->
    swingMessage.timestamp -= timeDelta
    if clientSocket.onswing? then clientSocket.onswing swingMessage

  # generic message from server - just log it
  socket.on "message", (data)-> console.log(data)

  # sever informing you what player you are
  socket.on "playerId", (id)-> playerId = id

  # notice from server about the time delta between client and server
  # the delta is sever - client
  # i.e to get to server time just add the delta to local client time
  socket.on "serverTime", (serverTime, originalRequestTime)=> 
    currentTime = new Date().getTime()
    oneWayLatency = (originalRequestTime - currentTime)/2
    timeDelta = serverTime - originalRequestTime - oneWayLatency

  # -----------------------------------------------------------------------------------------------
  # public API
  # -----------------------------------------------------------------------------------------------
  join: ->
    socket.emit "newPlayer", token

  swing:->
    if playerId? and timeDelta?
      socket.emit "swing", new SwingMessage(playerId, new Date().getTime() + timeDelta)

  onswing: ->

  getToken: -> token