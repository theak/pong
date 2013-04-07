console.log "hi"
window.onkeydown = (event)->
  switch event.keyCode
    when 90
      swing = new Swing new Date().valueOf(),
                        0,
                        "right",
                        null
      pongRound.addAction swing
    when 88
      swing = new Swing new Date().valueOf(),
                        1,
                        "right",
                        null
      pongRound.addAction swing



window.onload = ->

  # display the QR code for mobile phones to connect
  qrCode = document.body.e "img mobileCode", ->
    @src = "http://chart.googleapis.com/chart?cht=qr&chs=128x128&choe=UTF-8&chld=H|0&chl=http://http://10.1.10.20:8000/m.index.html"

  playerScores = [0, 0]

  # define court and ball
  court = document.body.e "court", ->
    @style.position = "absolute"
    @style.top = "150px"
    @style.left = "10px"
    @style.backgroundColor = "green"

    @ball = @e "ball", ->
      @style.width = "10px"
      @style.height = "10px"
      @style.backgroundColor = "blue"
      @style.position = "absolute"
      @style.borderRadius = "5px"

  # initialize a round
  pongRound = new PongRound new PongState(new Date().valueOf(),
                                          0.5, 
                                          0,
                                          0,
                                          0,
                                          1,
                                          2,
                                          null)

  window.onkeydown = (event)->
    switch event.keyCode
      when 90
        swing = new Swing new Date().valueOf(),
                          0,
                          "right",
                          null
        console.log "player 0 swing"
        pongRound.addAction swing
      when 88
        swing = new Swing new Date().valueOf(),
                          1,
                          "right",
                          null
        console.log "player 1 swing"
        pongRound.addAction swing

  # set up the swing receiver 
  new SwingReceiver (swingMessage)->
    swing = new Swing swingMessage.timestamp,
                      swingMessage.playerID,
                      swingMessage.side,
                      swingMessage.speed
    pongRound.addAction swing


  # define rendering loop
  renderingInterval = setInterval ->

    currentState = (pongRound.getStateAtTime new Date().valueOf())

    displayMultiplier = 300
    court.style.height = currentState.courtWidth * displayMultiplier + "px"
    court.style.width = currentState.courtLength * displayMultiplier + "px"
    court.ball.style.top = currentState.ballLocX * displayMultiplier + "px"
    court.ball.style.left = currentState.ballLocY * displayMultiplier + "px"
    if currentState.winner?
      playerScores[currentState.winner] += 1
      alert "Player " + currentState.winner + " has got a point! " + playerScores
      pongRound = new PongRound new PongState(new Date().valueOf(),
                                              0.5, 
                                              0,
                                              0,
                                              0,
                                              1,
                                              2,
                                              null)
      console.log pongRound.getStateAtTime new Date().valueOf()
  , 10