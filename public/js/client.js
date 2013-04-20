// Generated by CoffeeScript 1.3.3

window.onload = function() {
  var court, player0Score, player1Score, playerScores, pongRound, qrCode, renderingInterval;
  playerScores = [0, 0];
  pongRound = new PongRound(new PongState(new Date().valueOf(), 0.5, 0, 0, 0, 1, 2, null));
  qrCode = document.body.e("img mobileCode", function() {
    return this.src = "http://chart.googleapis.com/chart?cht=qr&chs=128x128&choe=UTF-8&chld=H|0&chl=http://http://10.1.10.20:8000/m.index.html#" + clientSocket.getToken();
  });
  player0Score = document.body.e("span player0Score", function() {
    this.t("0");
    this.style.position = "absolute";
    this.style.top = "150px";
    return this.style.left = "10px";
  });
  player1Score = document.body.e("span player1Score", function() {
    this.t("0");
    this.style.position = "absolute";
    this.style.top = "150px";
    return this.style.left = "600px";
  });
  court = document.body.e("court", function() {
    this.style.position = "absolute";
    this.style.top = "180px";
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
  clientSocket.onswing = function(swingMessage) {
    var newSwing;
    newSwing = new Swing(swingMessage.timestamp, swingMessage.playerId, swingMessage.side, swingMessage.speed);
    return pongRound.addAction(newSwing);
  };
  return renderingInterval = setInterval(function() {
    var currentState, displayMultiplier;
    currentState = pongRound.getStateAtTime(new Date().valueOf());
    displayMultiplier = 300;
    court.style.height = currentState.courtWidth * displayMultiplier + "px";
    court.style.width = currentState.courtLength * displayMultiplier + "px";
    court.ball.style.top = currentState.ballLocX * displayMultiplier + "px";
    return court.ball.style.left = currentState.ballLocY * displayMultiplier + "px";
  }, 10);
};
