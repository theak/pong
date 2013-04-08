window.onload = ->

  # -----------------------------------------------------------------------------------------------
  # local state
  # -----------------------------------------------------------------------------------------------
  playerScores = [0, 0]
  pongRound = new PongRound new PongState(new Date().valueOf(),
                                        0.5, 
                                        0,
                                        0,
                                        0,
                                        1,
                                        2,
                                        null)

  # -----------------------------------------------------------------------------------------------
  # set up the display
  # -----------------------------------------------------------------------------------------------
  # display the QR code for mobile phones to connect
  qrCode = document.body.e "img mobileCode", ->
    @src = "http://chart.googleapis.com/chart?cht=qr&chs=128x128&choe=UTF-8&chld=H|0&chl=http://http://10.1.10.20:8000/m.index.html#" + 
           clientSocket.getToken()
  console.log qrCode.src
  player0Score = document.body.e "span player0Score", ->
    @t "0"
    @style.position = "absolute"
    @style.top = "150px"
    @style.left = "10px"
  player1Score = document.body.e "span player1Score", ->
    @t "0"
    @style.position = "absolute"
    @style.top = "150px"
    @style.left = "600px"
  # define court and ball
  court = document.body.e "court", ->
    @style.position = "absolute"
    @style.top = "180px"
    @style.left = "10px"
    @style.backgroundColor = "green"

    @ball = @e "ball", ->
      @style.width = "10px"
      @style.height = "10px"
      @style.backgroundColor = "blue"
      @style.position = "absolute"
      @style.borderRadius = "5px"

  # -----------------------------------------------------------------------------------------------
  # receiving updates
  # -----------------------------------------------------------------------------------------------
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
  clientSocket.onswing = (swingMessage)->
    console.log "on swing triggered"
    console.log swingMessage
    newSwing = new Swing swingMessage.timestamp,
                         swingMessage.playerId,
                         swingMessage.side,
                         swingMessage.speed
    console.log newSwing
    pongRound.addAction newSwing


  # -----------------------------------------------------------------------------------------------
  # refine rendering loop
  # -----------------------------------------------------------------------------------------------
  renderingInterval = setInterval ->

    currentState = (pongRound.getStateAtTime new Date().valueOf())

    displayMultiplier = 300
    court.style.height = currentState.courtWidth * displayMultiplier + "px"
    court.style.width = currentState.courtLength * displayMultiplier + "px"
    court.ball.style.top = currentState.ballLocX * displayMultiplier + "px"
    court.ball.style.left = currentState.ballLocY * displayMultiplier + "px"
    if currentState.winner?
      playerScores[currentState.winner] += 1
      player0Score.innerHTML = playerScores[0]
      player1Score.innerHTML = playerScores[1]
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