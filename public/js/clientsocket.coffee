socket = io.connect("/")
receiver = null;

getTokenFromUrl = ->
  if window.location.href.indexOf("#") == -1
    alert "please specify a token"
    return false
  else 
    return window.location.href.split("#")[1]

token = getTokenFromUrl()

if token
  socket.on "connect", ->
    socket.emit('token', token)

  socket.on "message", (data)->
    if typeof data == "object"
      receiver.send(data)
    else
      console.log(data)

#for mobile, instantiate this class
class Swinger
  constructor: (@playerId, @token) ->
  swing: ->
    socket.emit "swing", new SwingMessage(this.playerId, new Date().getTime(), this.token)

#for desktop, instantiate this class:
class SwingReceiver
  constructor: (@callback) ->
    receiver = this
  send: (swing) ->
    this.callback(swing)

#these instantiations are here for example and test purposes
receiver = new SwingReceiver (swing) ->
  console.log("swing received! " + swing)
swinger = new Swinger 1, token
