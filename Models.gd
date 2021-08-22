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
	
	func getShortDescription():
		return "%s" % id
	
	func getDescriptionString():
		var desc = ""
		var toppingsString = ""
		
		if toppings.size() == 0:
			toppingsString = "none"
		else:
			for topping in toppings:
				toppingsString += "%s, " % topping
		
		desc += "id: %s\n" % id
		desc += "size: %s\n" % sizeLabel
		desc += "sauce: %s\n" % sauce
		desc += "cheese: %s\n" % cheese
		desc += "toppings: %s\n" % toppingsString
		desc += "status: %s\n" % Constants.PIZZA_STATUSES.keys()[status]
		
		return desc

class Receipt:
	var pizza = Pizza.new()
	var status = Constants.RECEIPT_STATUSES.new
	var lineItems = []
	var items = []
	
	var PRICES = {
		Constants.RECEIPT_LINE_ITEMS.topping: {
			Constants.TOPPINGS.mushrooms: .5,
			Constants.TOPPINGS.olives: .3,
			Constants.TOPPINGS.chikun: 1,
			Constants.TOPPINGS.basil: .2,
			Constants.TOPPINGS.tomatoes: .2,
			Constants.TOPPINGS.onions: .15,
		},
		Constants.RECEIPT_LINE_ITEMS.sauce: {
			Constants.SAUCES.alfredo: 1,
			Constants.SAUCES.marinara: .5,
			Constants.SAUCES.bbq: 1.3,
			Constants.SAUCES.none: 0,	
		},
		Constants.RECEIPT_LINE_ITEMS.cheese: {
			Constants.CHEESES.light: .75,
			Constants.CHEESES.normal: 1,
			Constants.CHEESES.heavy: 2,
			Constants.CHEESES.none: 0,
		},
		Constants.RECEIPT_LINE_ITEMS.size: {
			Constants.PIZZA_SIZES.six: 4,
			Constants.PIZZA_SIZES.ten: 7,
			Constants.PIZZA_SIZES.twelve: 10,
			Constants.PIZZA_SIZES.fourteen: 12,
		}
	}
	
	func changeStatus(newStatus):
		status = newStatus
		
	func addLineItem(type, value):
		var newLineItem = ""
		var cost = 0
		
		if type == Constants.RECEIPT_LINE_ITEMS.tax or type == Constants.RECEIPT_LINE_ITEMS.total:
			cost = value
		elif PRICES.has(type) and PRICES[type].has(value):
			cost = PRICES[type][value]
		
		lineItems.append([type, value, cost])
	
	func getItemsTotal():
		var total = 0
		
		for item in lineItems:
			total += item[2]
		
		return total
		
	func getSalesTax(total):
		return total * Constants.SALES_TAX
		
	func getTotalWithTax():
		var total = getItemsTotal()
		var tax = getSalesTax(total)
		
		return total + tax
		
	func getFormattedTotal():
		var total = getItemsTotal()
		var totalAsString = "%s" % total
		var cents = totalAsString.substr(totalAsString.find("."))
		
		if cents.length() == 0:
			totalAsString += ".00"
		elif cents.length() == 2:
			totalAsString += "0"
		
		return "$%s" % totalAsString
		
	func getFormattedTax():
		var tax = getSalesTax(getItemsTotal())
		var taxAsString = "%s" % tax
		var cents = taxAsString.substr(taxAsString.find("."))
		
		if cents.length() == 0:
			taxAsString += ".00"
		elif cents.length() == 2:
			taxAsString += "0"
		
		return "$%s" % taxAsString
	
	func finalize():
		var total = getItemsTotal()
		var tax = getSalesTax(total)
		
		addLineItem(Constants.RECEIPT_LINE_ITEMS.tax, tax)
		addLineItem(Constants.RECEIPT_LINE_ITEMS.total, total)
		
	func lineItemsString():
		var items = ""
		var toppingNames = Constants.TOPPINGS.keys()
		var sauceNames = Constants.SAUCES.keys()
		var cheeseNames = Constants.CHEESES.keys()
		var sizeNames = Constants.PIZZA_SIZE_LABELS
			
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
					
			items += "\n%s" % newLineItem
		
		return items
