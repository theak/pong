socket = io.connect("/")

if window.location.href.indexOf("#") == -1
  alert "please specify a token"
else 
  window.token = window.location.href.split("#")[1]
  
  socket.on "connect", ->
    socket.emit('token', token)

  socket.on "message", (data)->
    console.log data

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
  console.log(swing)
swinger = new Swinger 1, token
