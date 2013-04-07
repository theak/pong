socket = io.connect("/")
swinger = null;
receiver = null;

getTokenFromUrl = ->
  if window.location.href.indexOf("#") == -1
    alert "please specify a token"
    return false
  else 
    return window.location.href.split("#")[1]

class SwingMessage
  constructor: (@playerId, @timestamp, @token) ->

token = getTokenFromUrl()

if token
  socket.on "connect", ->
    socket.emit('token', token)
  
  socket.on "message", (data)->
    if typeof data == "object" and data != null
      receiver.send(data)
    else
      console.log(data)
  
  socket.on "playerId", (id) ->
    swinger.playerId = id

#for mobile, instantiate this class
class Swinger
  constructor: (@token) ->
    swinger = this
    socket.emit "newplayer", @token
    console.log "new swinger!"
  swing: ->
    if @playerId?
      socket.emit "swing", new SwingMessage(@playerId, new Date().getTime(), this.token)

#for desktop, instantiate this class:
class SwingReceiver
  constructor: (@callback) ->
    receiver = this
  send: (swing) ->
    this.callback(swing)

#these instantiations are here for example and test purposes
#receiver = new SwingReceiver (swing) ->
#  console.log("swing received! " + swing)
#swinger = new Swinger token
