now = () ->
  #returns time in milliseconds
  return new Date().getTime()


class PositionProcessor
  #class responsible for analyzing our position model
  #and detecting movement
  constructor: (@model) ->
    @movementWindow = 1000
    @range = {"alpha" : 360, "beta" : 180, "gamma" : 180}

  extremes: (history, attribute) ->
    #returns the longest distance between any two positions in 
    #the previous time window. distance is defined below.
    if history.length <= 0
      return {"min" : -1, "max" : -1, "distance" : 0}

    maxDistance = 0
    first = history[0]
    second = history[0]
    for i in history
      for j in history
        dist = @distance(i[attribute], j[attribute], @range[attribute])
        if dist > maxDistance
          maxDistance = dist
          first = i
          second = j
    min = Math.min first[attribute], second[attribute]
    max = Math.max first[attribute], second[attribute]
    return {"min" : min, "max" : max, "distance" : maxDistance}

  distance: (n, k, range) ->
    #returns d s.t. 0 <= d < r/2 and |n - k| - d % r = 0
    #
    #in words, imagine points on a circle of circumference
    #r. let one of these points on the circle arbitrarily be 0.
    #n and k are points on that circle, measured in distance 
    #(positive or negative) from 0. this function returns the
    #size of the shortest path between n and k. this path must 
    #always be less than half the circle's size and >= 0.


    # PROOF that d satisfies |n - k| - d % r, that d < r/2, d > 0:
    #       let n = n % r, k = k % r. now, |n| < r, |k| < r
    #       case 1: |n - k| is > r/2. then r - |n-k| < r/2. 
    #               hence, returns r - |n - k|
    #               |n - k| - (r - |n -k|) % r = 0

    #       case 2: |n - k| is < r/2. then r - |n - k| > r/2
    #               hence, returns |n - k|
    #               |n - k|  - |n - k| % r = 0
    #
    #       to see that d > 0, note that |n - k| >= 0 and that
    #       r - d, where d < r/2, is always greater than 0

    n = n % range
    k = k % range
    return Math.min Math.abs((n-k)), range - Math.abs((n-k))

  hasMoved: (lambda) ->
    positions = @model.read(@movementWindow)
    if positions.length <= 0
      return false

    alpha = @extremes(positions, "alpha")
    beta = @extremes(positions, "beta")
    gamma = @extremes(positions, "gamma")

    return alpha.distance > (7.0/8.0)*(@range["alpha"]/2.0) or
           beta.distance > (7.0/8.0)*(@range["beta"]/2.0) or 
           gamma.distance > (7.0/8.0)*(@range["gamma"]/2.0)



class PositionObserver
  #class responsible for updating our position model
  constructor: (@model) ->

  getPosition: () -> 
    location = gyro.getOrientation()
    return new PositionStruct now(), location.alpha, \
				                      location.beta, location.gamma
  track: () ->
    @model.write @getPosition()



class PositionModel  
  #model of where the phone has been.
  constructor: () ->
  	@history = []
  	@maxHistory = 2500

  obliterate: () ->
  	@history = []

  write: (positionStruct) ->
    @history.push positionStruct

    #make sure history isn't too long
    @history = @read @maxHistory

 	read: (age) ->
    time = now()
    return (position for position in @history \
            when time - position.age < age)



class PositionStruct
  #primitive data structure of position
  constructor: (@age, @alpha, @beta, @gamma) -> 



onMovement = (callback) -> 
  #calls callback whenever a movement has occurred.
  model = new PositionModel()
  observer = new PositionObserver(model)
  processor = new PositionProcessor(model)

  wrapper = (observer, processor, callback) ->
    delay = 50
    observer.track()
    console.log processor.model.history.length
    if processor.hasMoved()
      callback()
      model.obliterate()
      delay = 1000
    setTimeout (-> wrapper observer, processor, callback), delay
  wrapper observer, processor, callback 



#test code. 
onMovement(() ->
  $("body").append "moved <br />"
  if window.navigator.vibrate
    window.navigator.vibrate 500
)

