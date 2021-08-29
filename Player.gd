extends Node

class PizzaShop:
	var Name = "Pizzateria"
	var Level = 1
	var OpenOrders = []
	var CompletedOrders = []
	var AvailableToppings = Constants.TOPPINGS
	var AvailablePans = Constants.PIZZA_SIZES
	var AvailableSauces = Constants.SAUCES
	var AvailableCheeses = Constants.CHEESES
	var Ovens = [Models.Oven.new()]
	var Pizzas = []
	var Stats = {
		"pizzasMade": 0,
		"lifetimeIncome": 0,
		"daysInBusiness": 0,
		"customersServed": 0,
	}
	var Balance = 0
	var Phone = Models.Phone.new()
	
	var _id_incrementer = 0
	var _receipt_id_incrementer = 0
	
	func nextId():
		_id_incrementer += 1
		return _id_incrementer
		
	func nextReceiptId():
		_receipt_id_incrementer += 1
		return _receipt_id_incrementer
		
class ResidentsFactory:
	var residents = []
	
	func generateResident():
		residents.append(Models.Customer.new())
		
	func get(idx):
		return residents[idx]
		
var Shop = PizzaShop.new()
var Residents = ResidentsFactory.new()
