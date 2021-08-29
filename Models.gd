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
	var forDelivery = false
	var bakeTime = 0
	var numCuts = 0
	
	func _init():
		id = "pizza-%s" % Player.Shop.nextId()
	
	func changeStatus(newStatus):
		status = newStatus
		
	func isBaked():
		return status == Constants.PIZZA_STATUSES.baked
	
	func isBaking():
		return status == Constants.PIZZA_STATUSES.baking
	
	func isBoxed():
		return status == Constants.PIZZA_STATUSES.boxed
	
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
		if isBoxed: return
		
		isCut = true
		numCuts += 1
	
	func box():
		if status != Constants.PIZZA_STATUSES.baked: return
		
		isBoxed = true
		
	func setSize(newSize):
		size = newSize
		bakeTime = Constants.PIZZA_BAKE_TIMES[size]
		sizeLabel = Names.SIZES[size]
		
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
		
		return desc

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

class Customer:
	var Orders = []
	var openOrder = null
	var pizzaForOpenOrder = null
	var rng = RandomNumberGenerator.new()
	var name = ""
	var hunger = 0
	
	func _init():
		rng.randomize()
		name = Constants.CUSTOMER_NAMES[rng.randi() % Constants.CUSTOMER_NAMES.size()]
		
	func pickPizza():
		var pizza = Models.Pizza.new()
		
		pizza.setSize(pickSizeForPizza())
		pizza.setSauce(pickSauceForPizza())
		pizza.setCheese(pickCheeseForPizza())
		pizza.setToppings(pickToppingsForPizza())
		
		return pizza
	
	func pickSizeForPizza():
		var randomSize = rng.randi() % Constants.PIZZA_SIZES.size()
		return Constants.PIZZA_SIZES.values()[randomSize]
	
	func pickSauceForPizza():
		var randomSauce = rng.randi() % Constants.SAUCES.size()
		return Constants.SAUCES.values()[randomSauce]
	
	func pickCheeseForPizza():
		var randomCheese = rng.randi() % Constants.CHEESES.size()
		return Constants.CHEESES.values()[randomCheese]
	
	func pickToppingsForPizza():
		if rng.randi() % 3 == 1: 
			return []
		
		var numToppings = rng.randi() % 8 - 3
		
		if numToppings < 1: return []
		
		var toppings = []
		
		for i in numToppings:
			var randomTopping = Constants.TOPPINGS.values()[rng.randi() % Constants.TOPPINGS.size()]
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
			if chosenPizza.numToppings() == 1:
				toppingsString += Names.TOPPINGS[chosenPizza.toppings[0]]
			else:
				for t in chosenPizza.toppings.slice(0, chosenPizza.toppings.size() - 1):
					toppingsString += "%s..." % Names.TOPPINGS[t]
				toppingsString += " and %s" % Names.TOPPINGS[chosenPizza.toppings[-1]]
			dialog.append(toppingsString)
		else:
			dialog.append("and that's it!")
		
		return dialog
	
	func setOpenOrder(order):
		openOrder = order

	func fulfillOrder(items):
		openOrder.fulfill()
		Orders.append(openOrder)
		openOrder = null
		
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

	func fulfill(pizza):
		status = Constants.ORDER_STATUSES.fulfilled
		fulfillmentPizza = pizza
		pizzasMatch = checkIfPizzasMatch(desiredPizza, fulfillmentPizza)
	
	func checkIfPizzasMatch(pizza1, pizza2):
		print("checkIfPizzasMatch is not yet implemented")
		return true
		
class Phone:
	signal line_disconnected
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
				
			return Constants.PHONE_SIGNALS.ringing
		
		return Constants.PHONE_SIGNALS.busy
		
	func lineDisconnected(line):
		line.disconnected = true
	
	func acceptCallOnLine(lineId):
		if (!lines[lineId].isRinging): return false
		if (lines[lineId].disconnected):
			emit_signal("line_disconnected")
			return hangUpLine(lineId)
		
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
	var maxTemp = 750
	var style = "gas"
	var material = "stainless_steel"
	var max_capacity = 4
	var turnedOn = false
	var tempControlStepAmount = 50
	var items = []

