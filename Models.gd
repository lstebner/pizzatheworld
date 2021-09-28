extends Node
	
class Pizza:
	var id = ""
	var size = -1
	var sizeLabel = ""
	var sauce = -1
	var cheese = -1
	var toppings = []
	var status = Constants.PIZZA_STATUSES.ordered
	var isCut = false
	var isBoxed = false
	var isAttachedToOrder = false
	var bakeTime = 0
	var numCuts = 0
	
	func _init():
		id = "pizza-%s" % Player.Shop.nextId()
	
	func changeStatus(newStatus):
		status = newStatus
		
	func isBaked():
		return status >= Constants.PIZZA_STATUSES.baked
	
	func isBaking():
		return status == Constants.PIZZA_STATUSES.baking
	
	func isBoxed():
		return status == Constants.PIZZA_STATUSES.boxed
		
	func isCut():
		return numCuts > 0
	
	func isSizeSet():
		return size != -1
		
	func isSauceSet():
		return sauce != -1
	
	func isCheeseSet():
		return cheese != -1
	
	func hasToppings():
		return toppings.size() > 0
		
	func hasTopping(topping):
		return toppings.has(topping)
	
	func addCheese():
		if cheese == Constants.CHEESES.heavy: return
		
		if cheese == Constants.CHEESES.normal:
			cheese = Constants.CHEESES.heavy
		elif cheese == Constants.CHEESES.light:
			cheese = Constants.CHEESES.normal
		else:
			cheese = Constants.CHEESES.light
		
	func setNoCheese():
		cheese = Constants.CHEESES.none
	
	func setCheese(newCheese):
		cheese = newCheese
	
	func setSauce(newSauce):
		sauce = newSauce
	
	func setToppings(listOfToppings):
		toppings = listOfToppings
		
	func numToppings():
		return toppings.size()
		
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

		numCuts += 1
	
	func box():
		if status != Constants.PIZZA_STATUSES.baked: return
		
		status = Constants.PIZZA_STATUSES.boxed
		
	func setSize(newSize):
		size = newSize
		bakeTime = Constants.PIZZA_BAKE_TIMES[size]
		sizeLabel = Names.SIZES[size]
		
	func adjustBakeTimeForOvenTemp(ovenTemp):
		if ovenTemp >= 950: return
		
		bakeTime += (950 - ovenTemp) / 25
		
	func isComplete():
		# toppings are considered optional, everything else is required
		return isSizeSet() and isSauceSet() and isCheeseSet()
	
	func getShortDescription():
		return "%s" % id
	
	func getDescriptionString():
		var desc = ""
		var toppingsString = ""
		
		if toppings.size() == 0:
			toppingsString = "none"
		else:
			for topping in toppings:
				toppingsString += "%s, " % Names.TOPPINGS[topping]
		
		desc += "id: %s\n" % id
		desc += "size: %s\n" % sizeLabel
		desc += "sauce: %s\n" % Names.SAUCES[sauce]
		desc += "cheese: %s\n" % Names.CHEESES[cheese]
		desc += "toppings: %s\n" % toppingsString
		desc += "status: %s\n" % Constants.PIZZA_STATUSES.keys()[status]
		desc += "cuts: %s\n" % numCuts
		
		return desc
		
	func attachToOrder():
		isAttachedToOrder = true

class Receipt:
	var id = -1
	var pizza = Pizza.new()
	var status = Constants.RECEIPT_STATUSES.new
	var lineItems = []
	var items = []
	var timeCreated = null
	var total = 0
	var tax = 0
	var isFinal = false
	
	func _init():
		id = Player.Shop.nextReceiptId()
	
	func changeStatus(newStatus):
		status = newStatus
		
	func addLineItem(type, value):
		var newLineItem = ""
		var cost = 0
		
		if type == Constants.RECEIPT_LINE_ITEMS.tax or type == Constants.RECEIPT_LINE_ITEMS.total or type == Constants.RECEIPT_LINE_ITEMS.grandTotal:
			cost = value
		elif type == Constants.RECEIPT_LINE_ITEMS.timestamp:
			cost = "-"
		elif Constants.PRICES.has(type) and Constants.PRICES[type].has(value):
			cost = Constants.PRICES[type][value]
		
		lineItems.append([type, value, cost])
	
	func getItemsTotal():
		if isFinal:
			return total
			
		var itemsTotal = 0
		
		for item in lineItems:
			if item[0] != Constants.RECEIPT_LINE_ITEMS.timestamp:
				itemsTotal += item[2]
		
		return itemsTotal
		
	func getSalesTax(itemsTotal):
		if isFinal:
			return tax
			
		return itemsTotal * Constants.SALES_TAX
		
	func getTotalWithTax():
		if isFinal:
			return total + tax
		
		var itemsTotal = getItemsTotal()
		var salesTax = getSalesTax(total)
		
		return itemsTotal + salesTax
		
	func getFormattedTotal():
		var itemsTotal = getItemsTotal()
		var totalAsString = "%s" % itemsTotal
		var cents = totalAsString.substr(totalAsString.find("."))
		
		if cents.length() == 0:
			totalAsString += ".00"
		elif cents.length() == 2:
			totalAsString += "0"
		
		return "$%s" % totalAsString
		
	func getFormattedTax():
		var salesTax = getSalesTax(getItemsTotal())
		var taxAsString = "%s" % salesTax
		var cents = taxAsString.substr(taxAsString.find("."))
		
		if cents.length() == 0:
			taxAsString += ".00"
		elif cents.length() == 2:
			taxAsString += "0"
		
		return "$%s" % taxAsString
	
	func finalize():
		total = getItemsTotal()
		tax = getSalesTax(total)
		isFinal = true
		
		addLineItem(Constants.RECEIPT_LINE_ITEMS.tax, tax)
		addLineItem(Constants.RECEIPT_LINE_ITEMS.grandTotal, total + tax)
		addLineItem(Constants.RECEIPT_LINE_ITEMS.timestamp, GlobalWorld.timestamp())
		timeCreated = GlobalWorld.getCurrentTime()
		
	func lineItemsString():
		var items = ""
		var toppingNames = Names.TOPPINGS
		var sauceNames = Names.SAUCES
		var cheeseNames = Names.CHEESES
		var sizeNames = Names.SIZES
			
		for item in lineItems:
			var newLineItem = ""
			var type = item[0]
			var value = item[1]
			var cost = item[2]
			
			match type:
				Constants.RECEIPT_LINE_ITEMS.topping:
					newLineItem = "+TOPPING - %s @ $%s" % [toppingNames[value], cost]
				
				Constants.RECEIPT_LINE_ITEMS.sauce:
					newLineItem = "+SAUCE - %s @ $%s" % [sauceNames[value], cost]
					
				Constants.RECEIPT_LINE_ITEMS.cheese:
					newLineItem = "+CHEESE - %s @ $%s" % [cheeseNames[value], cost]
					
				Constants.RECEIPT_LINE_ITEMS.size:
					newLineItem = "+SIZE - %s @ $%s" % [sizeNames[value], cost]
				
				Constants.RECEIPT_LINE_ITEMS.tax:
					newLineItem = "+TAX - %s" % [cost]
				
				Constants.RECEIPT_LINE_ITEMS.total:
					newLineItem = "=TOTAL - %s" % [cost]
				
				Constants.RECEIPT_LINE_ITEMS.grandTotal:
					newLineItem = "=GTOTAL - %s" % [cost]

				Constants.RECEIPT_LINE_ITEMS.timestamp:
					newLineItem = "TIME @ %s" % [value]
					
			items += "\n%s" % newLineItem
		
		return items

enum CUSTOMER_STATES {
	chillin,
	sleeping,
	hungry,
	placing_order,
	waiting_for_delivery,
	eating,
	waiting_to_call_again,
}

class Customer:
	signal call_pizza_shop
	signal hungry
	signal full
	signal wake_up
	signal go_to_sleep
	signal waiting
	
	var Orders = []
	var openOrder = null
	var pizzaForOpenOrder = null
	var rng = RandomNumberGenerator.new()
	var name = ""
	var hunger = 50
	var hungerFullLevel = 100
	var metabolism = 1
	var currentState = CUSTOMER_STATES.chillin
	var nextState = currentState
	var bedtimeHour = 20
	var wakeupHour = 6
	var callAgainWaitTime = 0
	
	func _init():
		rng.randomize()
		name = Constants.CUSTOMER_NAMES[rng.randi_range(0, Constants.CUSTOMER_NAMES.size() - 1)]
	
	func _update(delta):
		if currentState != nextState:
			var previousState = currentState
			currentState = nextState
			stateUpdated(previousState)
		
		if currentState != CUSTOMER_STATES.sleeping and shouldBeAsleep(GlobalWorld.currentDate.hour):
			nextState = CUSTOMER_STATES.sleeping
		
		match (currentState):	
			CUSTOMER_STATES.eating:
				hunger += delta * hungerFullLevel / 10
				
				if hunger >= hungerFullLevel && rng.randi() % 6 == 0:
					nextState = CUSTOMER_STATES.chillin
			
			CUSTOMER_STATES.sleeping:
				hunger -= delta * metabolism * .25
				
				if GlobalWorld.currentDate.hour == wakeupHour:
					nextState = CUSTOMER_STATES.chillin
					
			CUSTOMER_STATES.hungry:
				nextState = CUSTOMER_STATES.placing_order
		
			CUSTOMER_STATES.chillin:
				if GlobalWorld.currentDate.hour == bedtimeHour:
					nextState = CUSTOMER_STATES.sleeping
				else:
					hunger -= (delta * metabolism)
					
					if hunger < 0 && rng.randi() % 4 == 0:
						nextState = CUSTOMER_STATES.hungry
			
			CUSTOMER_STATES.waiting_to_call_again:
				callAgainWaitTime -= delta
				
				if callAgainWaitTime < 0:
					nextState = CUSTOMER_STATES.chillin
	
	func stateUpdated(prevState):
		match currentState:
			CUSTOMER_STATES.hungry:
				emit_signal("hungry")
				
			CUSTOMER_STATES.sleeping:
				emit_signal("go_to_sleep")
				
			CUSTOMER_STATES.placing_order:
				emit_signal("call_pizza_shop")
				
			CUSTOMER_STATES.chillin:
				if prevState == CUSTOMER_STATES.sleeping:
					emit_signal("wake_up")
				elif prevState == CUSTOMER_STATES.eating:
					emit_signal("full")
					
			CUSTOMER_STATES.waiting_for_delivery:
				emit_signal("waiting")
	
	func setName(newName):
		name = newName
		
	func setSleepHours(bedtime, wakeup):
		bedtimeHour = bedtime
		wakeupHour = wakeup
		
	func setFullnessLevel(fullValue):
		hungerFullLevel = fullValue
		
	func setMetabolism(newMetabolism):
		metabolism = newMetabolism
		
	func shouldBeAsleep(currentHour):
		if currentHour >= bedtimeHour and (wakeupHour < bedtimeHour or currentHour < wakeupHour):
			return true
		elif currentHour < wakeupHour and (bedtimeHour > wakeupHour or bedtimeHour < currentHour):
			return true
		
		return false
	
	func pickPizza():
		var pizza = Models.Pizza.new()
		
		pizza.setSize(pickSizeForPizza())
		pizza.setSauce(pickSauceForPizza())
		pizza.setCheese(pickCheeseForPizza())
		pizza.setToppings(pickToppingsForPizza())
		
		return pizza
	
	func pickSizeForPizza():
		var availableSizes = Player.Shop.AvailableSizes
		var randomSize = rng.randi() % availableSizes.size()
		return availableSizes[randomSize]
	
	func pickSauceForPizza():
		var availableSauces = Player.Shop.AvailableSauces
		var randomSauce = rng.randi() % availableSauces.size()
		return availableSauces[randomSauce]
	
	func pickCheeseForPizza():
		var availableCheeses = Player.Shop.AvailableCheeses
		var randomCheese = rng.randi() % availableCheeses.size()
		return availableCheeses[randomCheese]
	
	func pickToppingsForPizza():
		if rng.randi() % 5 == 1: 
			return []
			
		var availableToppings = Player.Shop.AvailableToppings
		
		var numToppings = rng.randi() % 8 - 3
		
		if numToppings < 1: return []
		
		var toppings = []
		
		for i in numToppings:
			var randomTopping = availableToppings[rng.randi() % availableToppings.size()]
			if !toppings.has(randomTopping):
				toppings.append(randomTopping)
			
		return toppings
		
	func choosePizzaToOrder():
		pizzaForOpenOrder = pickPizza()
		return pizzaForOpenOrder
		
	func dialogForOrder():
		var chosenPizza = choosePizzaToOrder()
		var dialog = []
		var greetings = ["hello", "hi", "yo", ""]
		var randomGreeting = greetings[rng.randi() % greetings.size()]
		
		if GlobalWorld.currentDate.ampm == "am":
			greetings.append("good morning")
		else:
			greetings.append("good afternoon")
		
		# greeting
		if randomGreeting != "":
			dialog.append(randomGreeting)
		# size
		dialog.append("I would like a %s pizza," % Names.SIZES[chosenPizza.size])
		# sauce
		if chosenPizza.sauce == Constants.SAUCES.none:
			dialog.append("without sauce")
		else:
			dialog.append("with %s sauce," % Names.SAUCES[chosenPizza.sauce])
		# cheese
		if chosenPizza.cheese == Constants.CHEESES.none:
			dialog.append("without cheese")
		else:
			dialog.append("%s cheese," % Names.CHEESES[chosenPizza.cheese])
		# toppings
		if chosenPizza.hasToppings():
			var toppingsString = "and topped with "
			
			match chosenPizza.numToppings():
				1:
					toppingsString += Names.TOPPINGS[chosenPizza.toppings[0]]
				2:
					toppingsString += "%s.. and %s" % [Names.TOPPINGS[chosenPizza.toppings[0]], Names.TOPPINGS[chosenPizza.toppings[1]]]
				_:
					for t in chosenPizza.toppings.slice(0, chosenPizza.toppings.size() - 2):
						toppingsString += "%s..." % Names.TOPPINGS[t]
					toppingsString += " and %s" % Names.TOPPINGS[chosenPizza.toppings[-1]]
			dialog.append(toppingsString)
		else:
			dialog.append("and that's it!")
		
		return dialog
	
	func setOpenOrder(order):
		openOrder = order

	func fulfillOrder(items):
		if !openOrder: return
		
		openOrder.fulfill(items)
		# todo: check if item actually matches order
		Orders.append(openOrder)
		openOrder = null
		
		nextState = CUSTOMER_STATES.eating
		
	func waitForDelivery():
		if currentState != CUSTOMER_STATES.placing_order: return
		
		nextState = CUSTOMER_STATES.waiting_for_delivery
	
	func callRejected():
		nextState = CUSTOMER_STATES.waiting_to_call_again
		callAgainWaitTime = 10
		
class Order:
	var desiredPizza = null
	var fulfillmentPizza = null
	var status = Constants.ORDER_STATUSES.new
	var pizzasMatch = true
	var receipt = null
	var customerName = ""
	
	func setDesiredPizza(pizza):
		desiredPizza = pizza
	
	func setReceipt(theReceipt):
		receipt = theReceipt

	func setCustomerName(name):
		customerName = name

	func fulfill(fulfillmentItems, requireMatch = true):
		var pizza = fulfillmentItems[0]
		fulfillmentPizza = pizza
		status = Constants.ORDER_STATUSES.fulfilled
	
	
		
class Phone:
	signal line_disconnected(line)
	signal line_ringing(line)
	signal call_accepted(line)
	
	var numLines = 1
	var lines = [{
		"isRinging": false,
		"isBusy": false,
		"disconnected": false,
		"customer": null,
	}]
	var disconnectChance = .02
	var rng = RandomNumberGenerator.new()
	
	func _init():
		rng.randomize()
	
	func incomingCall(customer):
		var line = getOpenLine()
		
		if line:
			line.isRinging = true
			line.customer = customer
			
			if rng.randf() < disconnectChance:
				lineDisconnected(line)
			
			emit_signal("line_ringing", line)
			return line
		
		return null
		
	func lineDisconnected(line):
		line.disconnected = true
	
	func acceptCallOnLine(lineId):
		if (!lines[lineId].isRinging): return false
		if (lines[lineId].disconnected):
			emit_signal("line_disconnected", lines[lineId])
			hangUpLine(lineId)
			return
		
		lines[lineId].isRinging = false
		lines[lineId].isBusy = true
		emit_signal("call_accepted", lines[lineId])
		
	func hangUpLine(lineId):
		lines[lineId].isRinging = false
		lines[lineId].isBusy = false
		lines[lineId].disconnected = false
		lines[lineId].customer = null
		
	func getOpenLine():
		var openLine
		for line in lines:
			if line.isRinging == false and line.isBusy == false:
				return line
		
		return null
		
class Oven:
	var currentTemp = 0
	var targetTemp = 0
	var minTemp = 0
	var maxTemp = 500
	var style = Enums.OvenStyles.electric
	var material = Enums.OvenMaterials.stainless_steel
	var max_capacity = 1
	var turnedOn = false
	var tempControlStepAmount = 50
	var items = []

