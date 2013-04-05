# state represents all information needed to show a game
# an action takes a state and outputs another state
# an action can be composited from other actions
# game is a series of actions

# PongState = 
#   timestamp: int
#   ballLocX: number
#   ballLocY: number
#   ballSpeedX: number
#   ballSpeedY: number
class PongState
  constructor: (@timestamp, @ballLocX, @ballLocY, @ballSpeedX, @ballSpeedY)->

# abstract class representing actions
# an action has a timestamp which we use to order them by
# and an actOn which takes a state and returns a new state
class Action
  constructor: (@timestamp)->
  actOn: (state)->

# takes a state - and extrapolates it to the given timestamp
class Extrapolate extends Action
  actOn: (state)->
    timeGap = @timestamp - state.timestamp
    extrapolatedX = state.ballLocX + (timeGap * state.ballSpeedX)
    extrapolatedY = state.ballLocY + (timeGap * state.ballSpeedY)
    extrapolatedSpeedX = state.ballSpeedX
    extrapolatedSpeedY = state.ballSpeedY
    if extrapolatedX > 1
      extrapolatedX = 2 - extrapolatedX
      extrapolatedSpeedX *= -1
    else if extrapolatedX < 0
      extrapolatedX *= -1
      extrapolatedSpeedX *= -1
    new PongState @timestamp,
                  extrapolatedX,
                  extrapolatedY,
                  extrapolatedSpeedX,
                  extrapolatedSpeedY

# takes a state - extrapolates it, then modifies it by a player swing
class Swing extends Action
  constructor: (timestamp, @playerID, @side, @speed)-> super timestamp
  actOn: (state)->

    MAX_REACH = 0.1
    MAX_ANGLE = Math.PI/4

    extrapolatedState = new Extrapolate(@timestamp).actOn state

    # assume player 0 and right swing - change if otherwise
    gap = extrapolatedState.ballLocY
    if (@playerID is 1) then gap  = 1 - gap

    # ball out of reach - continue unmolested
    if gap < 0 or gap > MAX_REACH
      return extrapolatedState
    
    # ball is reach calculate reflected angle
    else
      contactAngle = MAX_ANGLE * gap/MAX_REACH
      if (@playerID is 1) then contactAngle  += Math.PI
      if (@side is "left") then contactAngle  += Math.PI - (2 * contactAngle)

      reflectedBallSpeedX = (extrapolatedState.ballSpeedX * 
                            Math.cos(2*contactAngle)) + 
                            (extrapolatedState.ballSpeedY * 
                            Math.sin(2*contactAngle))

      reflectedBallSpeedY = (extrapolatedState.ballSpeedX * 
                            Math.sin(2*contactAngle)) +
                            (extrapolatedState.ballSpeedY * 
                            -Math.cos(2*contactAngle))

      if reflectedBallSpeedX is 0 and reflectedBallSpeedY is 0
        reflectedBallSpeedY = 0.0005

      return new PongState extrapolatedState.timestamp,
                           extrapolatedState.ballLocX,
                           extrapolatedState.ballLocY,
                           reflectedBallSpeedX,
                           reflectedBallSpeedY
 
# representation of a game round - series of player swings
class PongRound

  actions = [] # list of actions defining the round - ordered by timestamp
  cachedStates = [] # list of state caches, the indices match the actions

  constructor: (@startState)->

  addAction: (newAction)->

    # insert the action into the correct location
    actions.push newAction
    actions.sort (a,b)-> a.timestamp - b.timestamp

    # invalidate old cache states of necessary
    newActionIndex = actions.indexOf newAction
    cachedStates = cachedStates[...newActionIndex]

  getStateAtTime: (timestamp)->

    # find the index of most recent action before or at the requested timestamp
    # -1 indicates there were no actions before or at the requested timestamp
    mostRecentIndex = -1
    for actionIndex in [(actions.length - 1)...-1]
      if actions[actionIndex].timestamp <= timestamp
        mostRecentIndex = actionIndex
        break

    # find the index of the most recent cache before or at the requested timestamp
    # -1 indicates no cache found
    mostRecentCachedIndex = Math.min (cachedStates.length - 1), mostRecentIndex

    # bring the cache up to speed if necessary
    while mostRecentCachedIndex < mostRecentIndex
      mostRecentCachedState = 
        if mostRecentCachedIndex >= 0 then cachedStates[mostRecentCachedIndex] 
        else @startState
      nextAction = actions[mostRecentCachedIndex + 1]
      nextState = nextAction.actOn mostRecentCachedState
      cachedStates[mostRecentCachedIndex + 1] = nextState
      mostRecentCachedIndex += 1

    # do the final extrapolation to the requested timestamp
    mostRecentState = 
      if mostRecentCachedIndex >= 0 then cachedStates[mostRecentIndex]
      else @startState
    new Extrapolate(timestamp).actOn mostRecentState



# test code
pongRound = new PongRound new PongState(new Date().valueOf(), 0, 0, 0, 0)

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
  court.style.width = COURT_SIZE + "px"
  court.style.height = COURT_SIZE + "px"
  court.style.backgroundColor = "green"

  ball = document.getElementById "ball"
  ball.style.width = "10px"
  ball.style.height = "10px"
  ball.style.backgroundColor = "blue"
  ball.style.position = "absolute"

  renderingInterval = setInterval ->
    startTime = new Date().valueOf()
    currentState = (pongRound.getStateAtTime new Date().valueOf())
    ball.style.left = COURT_SIZE * currentState.ballLocX + "px"
    ball.style.bottom = COURT_SIZE * currentState.ballLocY + "px"
    endTime = new Date().valueOf()
    console.log currentState.ballLocX + ", " + currentState.ballLocY
  , 10

window.stop = ->
  clearInterval renderingInterval