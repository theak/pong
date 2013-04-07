# initialize a round
pongRound = new PongRound new PongState(new Date().valueOf(),
                                        0.5, 
                                        0,
                                        0,
                                        0,
                                        1,
                                        2,
                                        null)


window.onkeypress = (event)-> 
  if event.keyCode is 122
    pongRound.addAction new Swing new Date().valueOf(), 0, "right", null
  else if event.keyCode = 120
    pongRound.addAction new Swing new Date().valueOf(), 1, "right", null

window.onload = ->

  # define core elements
  court = document.body.e "court", ->
    @style.position = "absolute"
    @style.top = "0px"
    @style.left = "0px"
    @style.backgroundColor = "green"

    @ball = @e "ball", ->
      @style.width = "10px"
      @style.height = "10px"
      @style.backgroundColor = "blue"
      @style.position = "absolute"
      @style.borderRadius = "5px"

  # define rendering loop
  renderingInterval = setInterval ->

    currentState = (pongRound.getStateAtTime new Date().valueOf())

    displayMultiplier = 300
    court.style.width = currentState.courtWidth * displayMultiplier + "px"
    court.style.height = currentState.courtLength * displayMultiplier + "px"
    court.ball.style.left = currentState.ballLocX * displayMultiplier + "px"
    court.ball.style.bottom = currentState.ballLocY * displayMultiplier + "px"
    if currentState.winner?
      alert "Player " + currentState.winner + " has won!"
      window.location.reload(false);
  , 10