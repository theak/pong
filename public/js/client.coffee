socket = io.connect("/")

# dummy socket thing to print it out
socket.on "message", (data)->
  console.log data

# for demo purposes
socket.emit "message", "a letter for the server"

window.onkeypress = (event)-> 
  if event.keyCode is 122
    pongRound.addAction new Swing new Date().valueOf(), 0, "right", null
  else if event.keyCode = 120
    pongRound.addAction new Swing new Date().valueOf(), 1, "right", null


window.onload = ->
  COURT_SIZE = 500

  court = document.getElementById "court"
  court.style.position = "absolute"
  court.style.top = "0px"
  court.style.left = "0px"
  court.style.backgroundColor = "red"

  ball = document.getElementById "ball"
  ball.style.width = "10px"
  ball.style.height = "10px"
  ball.style.backgroundColor = "blue"
  ball.style.position = "absolute"

  renderingInterval = setInterval ->

    startTime = new Date().valueOf()
    currentState = (pongRound.getStateAtTime new Date().valueOf())

    displayMultiplier = 300

    court.style.width = currentState.courtWidth * displayMultiplier + "px"
    court.style.height = currentState.courtLength * displayMultiplier + "px"

    ball.style.left = currentState.ballLocX * displayMultiplier + "px"
    ball.style.bottom = currentState.ballLocY * displayMultiplier + "px"

    if currentState.winner?
      alert "Player " + currentState.winner + " has won!"
      window.location.reload(false);

    endTime = new Date().valueOf()
  , 10

window.stop = ->
  clearInterval renderingInterval