# state represents all information needed to show a game
# an action takes a state and outputs another state
# an action can be composited from other actions
# game is a series of actions

# PongState = 
#   timestamp: int
#   ball:
#     location:
#       x: number
#       y: number
#     speed:
#       x: number
#       y: number
class PongState
  constructor: (@timestamp, @ball)->

class Ball
  constructor: (@location, @speed)->

class Location
  constructor: (@x, @y)->

class Speed
  constructor: (@x, @y)->

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
    extrapolatedLocation = new Location state.ball.location.x + 
                                        (timeGap * state.ball.speed.x),
                                        state.ball.location.y + 
                                        (timeGap * state.ball.speed.y)
    new PongState @timestamp,
                  new Ball extrapolatedLocation,
                           new Speed state.ball.speed.x,
                                     state.ball.speed.y

# takes a state - extrapolates it, then modifies it by a player swing
class Swing extends Action
  constructor: (timestamp, @playerID, @side, @speed)->
    super timestamp
  actOn: (state)->
    extrapolatedState = new Extrapolate(@timestamp).actOn state 
    extrapolatedState.ball.speed.x *= -1
    extrapolatedState.ball.speed.y *= -1
    if extrapolatedState.ball.speed.x is 0
      extrapolatedState.ball.speed.x = 0.001
    return extrapolatedState
  
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
pongRound = new PongRound new PongState new Date().valueOf(),
                                        new Ball (new Location 0, 0),
                                                 (new Speed 0, 0)

window.onkeypress = (event)-> if event.keyCode is 32
  pongRound.addAction new Swing new Date().valueOf(), null, null, null

renderingInterval = setInterval ->
  x = (pongRound.getStateAtTime new Date().valueOf()).ball.location.x
  displayString = ""
  for index in [0...Math.round(x*10)]
    displayString += " "
  displayString += "O"
  console.log displayString
, 100

window.stop = ->
  clearInterval renderingInterval