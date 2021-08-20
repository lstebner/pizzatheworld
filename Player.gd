extends Node

# test data
var receipt = {
	"pizza": {
		"size": Constants.PIZZA_SIZES.six,
		"sauce": "Marinara",
		"cheese": "regular",
		"toppings": ["Mushrooms", "Olives"],
		"for_dine_in": false,
		"quantity": 1,
		"status": "",
	},
	"status": "order_placed",
	"items": [],
}
# test data
var receipt2 = {
	"pizza": {
		"size": Constants.PIZZA_SIZES.twelve,
		"sauce": "Marinara",
		"cheese": "light",
		"toppings": ["everything"],
		"for_dine_in": true,
		"quantity": 1,
		"status": "",
	},
	"status": "order_placed",
	"items": [],
}

var Shop = {
	"Name": "Pizzerteria",
	"Level": 1,
	"OpenOrders": [receipt, receipt2],
	"CompletedOrders": [],
	"AvailableToppings": [],
	"AvailablePans": [],
	"AvailableSauces": [],
	"AvailableCheeses": [],
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
	"Stats": {},
	"Balance": 0,
}
