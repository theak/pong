socket = io.connect("/")

getTokenFromUrl = ->
  if window.location.href.indexOf("#") == -1
    alert "please specify a token"
    return false
  else 
    return window.location.href.split("#")[1]
token = getTokenFromUrl()

class SwingMessage
  constructor: (@playerId, @timestamp, @token) ->

if token
  socket.on "connect", ->
    socket.emit('token', token)

  socket.on "message", (data)->
    if data != null and typeof data == "object" and SwingReceiver.singleton?
      SwingReceiver.singleton.send(data)
    else
      console.log(data)
  
  socket.on "playerId", (id, delta) ->
    Swinger.singleton.playerId = id
    Swinger.singleton.delta = delta

#for mobile, instantiate this class
class Swinger
  singleton: null
  constructor: (@token) ->
    Swinger.singleton = this
    socket.emit "newplayer", @token, new Date().getTime()
    console.log "new swinger!"
  swing: ->
    if @playerId? and @delta?
      socket.emit "swing", new SwingMessage(@playerId, new Date().getTime() + @delta, this.token)

#for desktop, instantiate this class:
class SwingReceiver
  singleton: null
  constructor: (@callback) ->
    SwingReceiver.singleton = this
  send: (swing) ->
    this.callback(swing)

#these instantiations are here for example and test purposes
#receiver = new SwingReceiver (swing) ->
#  console.log("swing received! " + swing)
#swinger = new Swinger token
