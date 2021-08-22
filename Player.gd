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
	var Ovens = [{
		"currentTemp": 0,
		"targetTemp": 0,
		"minTemp": 200,
		"maxTemp": 750,
		"style": "gas",
		"material": "stainless_steel",
		"max_capacity": 4,
		"turnedOn": false,
		"tempControlStepAmount": 50,
		"items": [],
	}]
	var Pizzas = []
	var Stats = {
		"pizzasMade": 0,
		"lifetimeIncome": 0,
		"daysInBusiness": 0,
		"customersServed": 0,
	}
	var Balance = 0
	
	var _id_incrementer = 0
	
	func nextId():
		_id_incrementer += 1
		return _id_incrementer
		
var Shop = PizzaShop.new()
