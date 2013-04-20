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
    log "socket|on|connect"
    socket.emit 'joinRoom', token
    log "socket|emit|joinRoom|" + token
    requestTime = new Date().getTime()
    socket.emit "getServerTime", (serverTime)->
      log "socket|callback|getServerTime|" + serverTime
      replyTime = new Date().getTime()
      timeDelta = serverTime - (requestTime/2) - (replyTime/2)
    log "socket|emit|getServerTime"

  # received a swing event from the server - propagate to all receivers
  socket.on "swing", (swingMessage)->
    log "socket|on|swing|" + JSON.stringify swingMessage
    swingMessage.timestamp -= timeDelta
    console.log timeDelta
    console.log "received delay " + (new Date().getTime() - swingMessage.timestamp)
    if clientSocket.onswing? then clientSocket.onswing swingMessage

  # generic message from server - just log it
  socket.on "message", (data)-> 
    log "socket|on|message|" + data.toString()

  # -----------------------------------------------------------------------------------------------
  # public API
  # -----------------------------------------------------------------------------------------------
  join: ->
    socket.emit "newPlayer", token, (id)->
      log "socket|callback|newPlayer|" + id
      playerId = id
    log "socket|emit|newPlayer|" + token

  swing:->
    if playerId? and timeDelta?
      swingMessage = new SwingMessage(playerId, new Date().getTime())
      swingMessage.timestamp += timeDelta
      socket.emit "swing", swingMessage
      log "socket|emit|swing|" + JSON.stringify swingMessage

  onswing: ->

  getToken: -> token