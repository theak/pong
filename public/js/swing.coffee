class Swing
	constructor: (@playerId, @timestamp, @gameToken)
	#returns json string
	toString: ->
		return JSON.stringify(this)
