extends Node

var Shop = {
	"Name": "Pizzerteria",
	"Level": 1,
	"OpenOrders": [],
	"CompletedOrders": [],
	"AvailableToppings": Constants.TOPPINGS,
	"AvailablePans": Constants.PIZZA_SIZES,
	"AvailableSauces": Constants.SAUCES,
	"AvailableCheeses": Constants.CHEESES,
	"Ovens": [{
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
	}],
	"Stats": {
		"pizzasMade": 0,
		"lifetimeIncome": 0,
		"daysInBusiness": 0,
		"customersServed": 0,
	},
	"Balance": 0,
}
