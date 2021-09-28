extends Node

class PizzaShop:
	signal phone_ringing(line)
	signal call_rejected(line)
	signal call_accepted(line)
	
	var Name = "Pizzateria"
	var Level = 1
	var OpenOrders = []
	var CompletedOrders = []
	var AvailableToppings = [Constants.TOPPINGS.olives, Constants.TOPPINGS.bananaPeppers, Constants.TOPPINGS.basil]
	var AvailableSizes = [Constants.PIZZA_SIZES.six, Constants.PIZZA_SIZES.twelve]
	var AvailableSauces = [Constants.SAUCES.marinara, Constants.SAUCES.none]
	var AvailableCheeses = [Constants.CHEESES.normal, Constants.CHEESES.none]
	var Ovens = [Models.Oven.new()]
	var Pizzas = []
	var Balance = 0
	var Phone = Models.Phone.new()
	
	var _id_incrementer = 0
	var _receipt_id_incrementer = 0
	
	func _init():
		Phone.connect("line_ringing", self, "_on_phone_line_ringing")
		Phone.connect("line_disconnected", self, "_on_phone_line_disconnected")
		Phone.connect("call_accepted", self, "_on_phone_call_accepted")
		GlobalWorld.connect("day_changed", self, "_on_day_changed")
		pass
		
	func nextId():
		_id_incrementer += 1
		return _id_incrementer
		
	func nextReceiptId():
		_receipt_id_incrementer += 1
		return _receipt_id_incrementer
		
	func incomingCall(customer):
		return Phone.incomingCall(customer)
	
	func answerPhone(lineId):
		Phone.acceptCallOnLine(lineId)
	
	func hangUpPhoneLine(lineId):
		Phone.hangUpLine(lineId)
		
	func orderCompleted(order):
		var incomeEarned = order.receipt.getTotalWithTax()
		Balance += incomeEarned
		LifetimeStats.addToIncomeToday(incomeEarned)
		LifetimeStats.incrementPizzasDeliveredToday()
		
	func _on_phone_line_ringing(line):
		emit_signal("phone_ringing", line)
	
	func _on_phone_line_disconnected(line):
		emit_signal("call_rejected", line)
	
	func _on_phone_call_accepted(line):
		emit_signal("call_accepted", line)
		
	func _on_day_changed():
		LifetimeStats.updateForEndOfDay()
		
class ResidentsFactory:
	var residents = []
	
	func generateResident():
		residents.append(Models.Customer.new())
		
	func get(idx):
		return residents[idx]
		
var Shop = PizzaShop.new()
var Residents = ResidentsFactory.new()
