// Generated by CoffeeScript 1.3.3

console.log("hi");

window.onkeydown = function(event) {
  var swing;
  switch (event.keyCode) {
    case 90:
      swing = new Swing(new Date().valueOf(), 0, "right", null);
      return pongRound.addAction(swing);
    case 88:
      swing = new Swing(new Date().valueOf(), 1, "right", null);
      return pongRound.addAction(swing);
  }
};

window.onload = function() {
  var court, playerScores, pongRound, qrCode, renderingInterval;
  qrCode = document.body.e("img mobileCode", function() {
    return this.src = "http://chart.googleapis.com/chart?cht=qr&chs=128x128&choe=UTF-8&chld=H|0&chl=http://http://10.1.10.20:8000/m.index.html";
  });
  playerScores = [0, 0];
  court = document.body.e("court", function() {
    this.style.position = "absolute";
    this.style.top = "150px";
    this.style.left = "10px";
    this.style.backgroundColor = "green";
    return this.ball = this.e("ball", function() {
      this.style.width = "10px";
      this.style.height = "10px";
      this.style.backgroundColor = "blue";
      this.style.position = "absolute";
      return this.style.borderRadius = "5px";
    });
  });
  pongRound = new PongRound(new PongState(new Date().valueOf(), 0.5, 0, 0, 0, 1, 2, null));
  window.onkeydown = function(event) {
    var swing;
    switch (event.keyCode) {
      case 90:
        swing = new Swing(new Date().valueOf(), 0, "right", null);
        console.log("player 0 swing");
        return pongRound.addAction(swing);
      case 88:
        swing = new Swing(new Date().valueOf(), 1, "right", null);
        console.log("player 1 swing");
        return pongRound.addAction(swing);
    }
  };
  new SwingReceiver(function(swingMessage) {
    var swing;
    swing = new Swing(swingMessage.timestamp, swingMessage.playerID, swingMessage.side, swingMessage.speed);
    return pongRound.addAction(swing);
  });
  return renderingInterval = setInterval(function() {
    var currentState, displayMultiplier;
    currentState = pongRound.getStateAtTime(new Date().valueOf());
    displayMultiplier = 300;
    court.style.height = currentState.courtWidth * displayMultiplier + "px";
    court.style.width = currentState.courtLength * displayMultiplier + "px";
    court.ball.style.top = currentState.ballLocX * displayMultiplier + "px";
    court.ball.style.left = currentState.ballLocY * displayMultiplier + "px";
    if (currentState.winner != null) {
      playerScores[currentState.winner] += 1;
      alert("Player " + currentState.winner + " has got a point! " + playerScores);
      pongRound = new PongRound(new PongState(new Date().valueOf(), 0.5, 0, 0, 0, 1, 2, null));
      return console.log(pongRound.getStateAtTime(new Date().valueOf()));
    }
  }, 10);
};
