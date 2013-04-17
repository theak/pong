now = () ->
  #returns time in milliseconds
  return new Date().getTime()
ranges = {"alpha" : 360, "beta" : 180, "gamma" : 180}

class PositionProcessor
  movementWindow = 1000

  #class responsible for analyzing our position model
  #and detecting movement
  constructor: (@model) ->

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
        dist = @distance(i[attribute], j[attribute], ranges[attribute])
        if dist > maxDistance
          maxDistance = dist
          first = i
          second = j
    min = Math.min first[attribute], second[attribute]
    max = Math.max first[attribute], second[attribute]
    return {"min" : min, "max" : max, "distance" : maxDistance}

  distance: (n, k, r) ->
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

    n = n % r
    k = k % r
    return Math.min Math.abs((n-k)), r - Math.abs((n-k))

  sign: (first, second, range) ->
    d = @distance(first, second, range)
    #case 1: fastest route between first and second in circle space
    #        is first - d 
    if first - d == second or range + first - d == second
      return "pos"

    #case 2: fastest route between first and second in circle space
    #        is first + d 
    if first + d == second or first + d == second + range
      return "neg"

    return "zero"

  cardinality: () ->
    positions = @model.read(movementWindow)
    if positions.length <= 3
      return "rightToLeft"

    signCount = {"zero":0, "pos":0, "neg":0}

    #of the last 6 position pairs, only examine the first four.
    positionsToExamine = positions.reverse()
    positionsToExamine = positionsToExamine[0..6]

    for position, i in positionsToExamine[0..positionsToExamine.length - 3]
      first = positions[i].alpha
      second = positions[i+1].alpha
      signCount[@sign(first, second, ranges["alpha"])] += 1
      #$("body").append(positions[i].alpha + " <br />")

    if signCount["pos"] > signCount["neg"]
      return "leftToRight"
    return "rightToLeft"

  hasMoved: () ->
    positions = @model.read(movementWindow)
    if positions.length <= 3
      return false

    alpha = @extremes(positions, "alpha")
    beta = @extremes(positions, "beta")
    gamma = @extremes(positions, "gamma")

    return alpha.distance > (6.0/8.0)*(ranges["alpha"]/2.0) or
           beta.distance > (6.0/8.0)*(ranges["beta"]/2.0) or 
           gamma.distance > (6.0/8.0)*(ranges["gamma"]/2.0)



class PositionObserver
  #class responsible for updating our position model
  constructor: (@model) ->

  getPosition: () -> 
    #for ease of calculations, shift all alpha, beta, gamma
    #ranges to be > 0
    position = gyro.getOrientation()
    return new PositionStruct now(), \
                              Math.round position.alpha, \
				                      Math.round(position.beta + ranges["beta"]/2), \
                              Math.round(position.gamma + ranges["gamma"]/2)
  track: () ->
    @model.write @getPosition()



class PositionModel  
  #model of where the phone has been.
  history = []
  maxHistory = 2500

  obliterate: () ->
  	history = []

  write: (positionStruct) ->
    history.push positionStruct

    #make sure history isn't too long
    history = @read maxHistory

 	read: (age) ->
    time = now()
    return (position for position in history \
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
    if processor.hasMoved()
      callback(processor.cardinality())
      model.obliterate()
      delay = 1000
    setTimeout (-> wrapper observer, processor, callback), delay
  wrapper observer, processor, callback 


swinger = new Swinger(getTokenFromUrl())
onMovement (direction) -> 
  swinger.swing()
  document.body.style.backgroundColor = 'blue'


###
# #test code. 
onMovement((direction) ->
  $("body").append("moved" + direction + " <br />")
  if window.navigator.vibrate
    window.navigator.vibrate 500
 )
###
 

