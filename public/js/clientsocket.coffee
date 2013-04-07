socket = io.connect("/")
if window.location.href.indexOf("#") == -1
  alert "please specify a token"
else 
  token = window.location.href.split("#")[1]
  socket.on "message", (data)->
    console.log data
  
class Swinger
  constructor: (@playerId, @token)
  
  swing: ->
    socket.emit "message", new Swing(playerId, new Date().getTime(), token)
