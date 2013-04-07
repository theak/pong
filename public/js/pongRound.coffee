# state represents all information needed to show a game
# an action takes a state and outputs another state
# an action can be composited from other actions
# game is a series of actions
class PongState
  constructor: (@timestamp,
                @ballLocX, 
                @ballLocY, 
                @ballSpeedX, 
                @ballSpeedY,
                @courtWidth,
                @courtLength,
                @winner)->

# abstract class representing actions
# an action has a timestamp which we use to order them by
# and an actOn which takes a state and returns a new state
class Action
  constructor: (@timestamp)->
  actOn: (state)->

# takes a state - and extrapolates it to the given timestamp
class Extrapolate extends Action
  actOn: (state)->

    # basic extrapolation of the ball
    timeGap = @timestamp - state.timestamp
    extrapolatedX = state.ballLocX + (timeGap * state.ballSpeedX)
    extrapolatedY = state.ballLocY + (timeGap * state.ballSpeedY)
    extrapolatedSpeedX = state.ballSpeedX
    extrapolatedSpeedY = state.ballSpeedY

    # ball bouncing across the edges of the field
    residualX = extrapolatedX % state.courtWidth
    bounceCount = Math.floor extrapolatedX/state.courtWidth
    extrapolatedX = residualX * Math.pow(-1, bounceCount)
    if extrapolatedX < 0 then extrapolatedX += 1
    extrapolatedSpeedX *= Math.pow(-1, bounceCount)

    # check to see if someone wins
    if state.winner?
      winner = state.winner
    else
      if extrapolatedY < 0 then winner = 1
      else if extrapolatedY > state.courtLength then winner = 0

    new PongState @timestamp,
                  extrapolatedX,
                  extrapolatedY,
                  extrapolatedSpeedX,
                  extrapolatedSpeedY,
                  state.courtWidth,
                  state.courtLength,
                  winner


# takes a state - extrapolates it, then modifies it by a player swing
class Swing extends Action
  constructor: (timestamp, @playerID, @side, @speed)-> super timestamp
  actOn: (state)->

    MAX_REACH = 0.1
    MAX_ANGLE = Math.PI/6

    # bring the state up to the current time before applying the swing
    extrapolatedState = new Extrapolate(@timestamp).actOn state

    # assume player 0 and right swing - change if otherwise
    gap = extrapolatedState.ballLocY
    if (@playerID is 1) then gap = extrapolatedState.courtLength - gap

    # ball out of reach - continue unmolested
    if gap < 0 or gap > MAX_REACH
      return extrapolatedState
    
    # ball is reach calculate reflected angle
    else
      contactAngle = MAX_ANGLE * gap/MAX_REACH
      if (@playerID is 1) then contactAngle += Math.PI
      if (@side is "left") then contactAngle += Math.PI - (2 * contactAngle)

      reflectedBallSpeedX = (extrapolatedState.ballSpeedX * 
                            Math.cos(2*contactAngle)) + 
                            (extrapolatedState.ballSpeedY * 
                            Math.sin(2*contactAngle))

      reflectedBallSpeedY = (extrapolatedState.ballSpeedX * 
                            Math.sin(2*contactAngle)) +
                            (extrapolatedState.ballSpeedY * 
                            -Math.cos(2*contactAngle))

      if reflectedBallSpeedX is 0 and reflectedBallSpeedY is 0
        reflectedBallSpeedY = 0.001

      return new PongState extrapolatedState.timestamp,
                           extrapolatedState.ballLocX,
                           extrapolatedState.ballLocY,
                           reflectedBallSpeedX,
                           reflectedBallSpeedY,
                           extrapolatedState.courtWidth,
                           extrapolatedState.courtLength,
                           extrapolatedState.winner
 
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