// Generated by CoffeeScript 1.3.3
var Action, Extrapolate, PongRound, PongState, Swing,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

PongState = (function() {

  function PongState(timestamp, ballLocX, ballLocY, ballSpeedX, ballSpeedY, courtWidth, courtLength, winner) {
    this.timestamp = timestamp;
    this.ballLocX = ballLocX;
    this.ballLocY = ballLocY;
    this.ballSpeedX = ballSpeedX;
    this.ballSpeedY = ballSpeedY;
    this.courtWidth = courtWidth;
    this.courtLength = courtLength;
    this.winner = winner;
  }

  return PongState;

})();

Action = (function() {

  function Action(timestamp) {
    this.timestamp = timestamp;
  }

  Action.prototype.actOn = function(state) {};

  return Action;

})();

Extrapolate = (function(_super) {

  __extends(Extrapolate, _super);

  function Extrapolate() {
    return Extrapolate.__super__.constructor.apply(this, arguments);
  }

  Extrapolate.prototype.actOn = function(state) {
    var bounceCount, extrapolatedSpeedX, extrapolatedSpeedY, extrapolatedX, extrapolatedY, residualX, timeGap, winner;
    timeGap = this.timestamp - state.timestamp;
    extrapolatedX = state.ballLocX + (timeGap * state.ballSpeedX);
    extrapolatedY = state.ballLocY + (timeGap * state.ballSpeedY);
    extrapolatedSpeedX = state.ballSpeedX;
    extrapolatedSpeedY = state.ballSpeedY;
    residualX = extrapolatedX % state.courtWidth;
    bounceCount = Math.floor(extrapolatedX / state.courtWidth);
    extrapolatedX = residualX * Math.pow(-1, bounceCount);
    if (extrapolatedX < 0) {
      extrapolatedX += 1;
    }
    extrapolatedSpeedX *= Math.pow(-1, bounceCount);
    if (state.winner != null) {
      winner = state.winner;
    } else {
      if (extrapolatedY < 0) {
        winner = 1;
      } else if (extrapolatedY > state.courtLength) {
        winner = 0;
      }
    }
    return new PongState(this.timestamp, extrapolatedX, extrapolatedY, extrapolatedSpeedX, extrapolatedSpeedY, state.courtWidth, state.courtLength, winner);
  };

  return Extrapolate;

})(Action);

Swing = (function(_super) {

  __extends(Swing, _super);

  function Swing(timestamp, playerID, side, speed) {
    this.playerID = playerID;
    this.side = side;
    this.speed = speed;
    Swing.__super__.constructor.call(this, timestamp);
  }

  Swing.prototype.actOn = function(state) {
    var MAX_ANGLE, MAX_REACH, contactAngle, extrapolatedState, gap, reflectedBallSpeedX, reflectedBallSpeedY;
    MAX_REACH = 0.4;
    MAX_ANGLE = Math.PI / 6;
    extrapolatedState = new Extrapolate(this.timestamp).actOn(state);
    gap = extrapolatedState.ballLocY;
    if (this.playerID === 1) {
      gap = extrapolatedState.courtLength - gap;
    }
    if (gap < 0 || gap > MAX_REACH) {
      return extrapolatedState;
    } else {
      contactAngle = MAX_ANGLE * gap / MAX_REACH;
      if (this.playerID === 1) {
        contactAngle += Math.PI;
      }
      if (this.side === "left") {
        contactAngle += Math.PI - (2 * contactAngle);
      }
      reflectedBallSpeedX = (extrapolatedState.ballSpeedX * Math.cos(2 * contactAngle)) + (extrapolatedState.ballSpeedY * Math.sin(2 * contactAngle));
      reflectedBallSpeedY = (extrapolatedState.ballSpeedX * Math.sin(2 * contactAngle)) + (extrapolatedState.ballSpeedY * -Math.cos(2 * contactAngle));
      if (reflectedBallSpeedX === 0 && reflectedBallSpeedY === 0) {
        reflectedBallSpeedY = 0.001;
      }
      return new PongState(extrapolatedState.timestamp, extrapolatedState.ballLocX, extrapolatedState.ballLocY, reflectedBallSpeedX, reflectedBallSpeedY, extrapolatedState.courtWidth, extrapolatedState.courtLength, extrapolatedState.winner);
    }
  };

  return Swing;

})(Action);

PongRound = (function() {

  function PongRound(startState) {
    this.startState = startState;
    this.actions = [];
    this.cachedStates = [];
  }

  PongRound.prototype.addAction = function(newAction) {
    var newActionIndex;
    this.actions.push(newAction);
    this.actions.sort(function(a, b) {
      return a.timestamp - b.timestamp;
    });
    newActionIndex = this.actions.indexOf(newAction);
    return this.cachedStates = this.cachedStates.slice(0, newActionIndex);
  };

  PongRound.prototype.getStateAtTime = function(timestamp) {
    var actionIndex, mostRecentCachedIndex, mostRecentCachedState, mostRecentIndex, mostRecentState, nextAction, nextState, _i, _ref;
    mostRecentIndex = -1;
    for (actionIndex = _i = _ref = this.actions.length - 1; _ref <= -1 ? _i < -1 : _i > -1; actionIndex = _ref <= -1 ? ++_i : --_i) {
      if (this.actions[actionIndex].timestamp <= timestamp) {
        mostRecentIndex = actionIndex;
        break;
      }
    }
    mostRecentCachedIndex = Math.min(this.cachedStates.length - 1, mostRecentIndex);
    while (mostRecentCachedIndex < mostRecentIndex) {
      mostRecentCachedState = mostRecentCachedIndex >= 0 ? this.cachedStates[mostRecentCachedIndex] : this.startState;
      nextAction = this.actions[mostRecentCachedIndex + 1];
      nextState = nextAction.actOn(mostRecentCachedState);
      this.cachedStates[mostRecentCachedIndex + 1] = nextState;
      mostRecentCachedIndex += 1;
    }
    mostRecentState = mostRecentCachedIndex >= 0 ? this.cachedStates[mostRecentIndex] : this.startState;
    return new Extrapolate(timestamp).actOn(mostRecentState);
  };

  return PongRound;

})();
