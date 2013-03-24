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

class Location
  constructor: (@x, @y)->

class Speed
  constructor: (@x, @y)->

class Ball
  constructor: (@location, @speed)->

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
    for actionIndex in [(actions.length - 1)...0] by -1
      if actions[actionIndex].timestamp <= timestamp
        mostRecentIndex = actionIndex
        break

    # find the index of the most recent cache before or at the requested timestamp
    # -1 indicates no cache found
    mostRecentCachedIndex = Math.min (cachedStates.length - 1), mostRecentIndex

    # bring the cache up to speed if necessary
    while mostRecentCachedIndex < mostRecentIndex
      mostRecentCachedState = cachedStates[mostRecentCachedIndex]
      nextAction = actions[mostRecentCachedIndex + 1]
      nextState = nextAction.actOn mostRecentCachedState
      cachedStates[mostRecentCachedIndex + 1] = nextState
      mostRecentCachedIndex += 1

    # do the final extrapolation to the requested timestamp
    mostRecentState = cachedStates[mostRecentIndex]
    new Extrapolate(timestamp).actOn mostRecentState

