extends Node

class Pizza:
	var id = ""
	var size = -1
	var sizeLabel = ""
	var sauce = ""
	var cheese = ""
	var toppings = []
	var status = Constants.PIZZA_STATUSES.ordered
	var isCut = false
	var isBoxed = false
	var forDelivery = false
	var bakeTime = 0
	var numCuts = 0
	
	func changeStatus(newStatus):
		status = newStatus
		
	func isBaked():
		return status == Constants.PIZZA_STATUSES.baked
	
	func isBoxed():
		return status == Constants.PIZZA_STATUSES.boxed
		
	func finishPrep():
		if !isComplete(): return
		
		changeStatus(Constants.PIZZA_STATUSES.prepped)
		
	func startBaking():
		if status != Constants.PIZZA_STATUSES.prepped: return
		
		changeStatus(Constants.PIZZA_STATUSES.baking)
	
	func completeBaking():
		if status != Constants.PIZZA_STATUSES.baking: return
		
		changeStatus(Constants.PIZZA_STATUSES.baked)
	
	func cut():
		if status != Constants.PIZZA_STATUSES.baked: return
		if isBoxed: return
		
		isCut = true
		numCuts += 1
	
	func box():
		if status != Constants.PIZZA_STATUSES.baked: return
		
		isBoxed = true
		
	func setSize(newSize):
		size = newSize
		bakeTime = Constants.PIZZA_BAKE_TIMES[size]
		sizeLabel = Constants.PIZZA_SIZE_LABELS[size]
		
	func isComplete():
		# toppings are considered optional, everything else is required
		return size != -1 and sauce != "" and cheese != ""
