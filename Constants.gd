extends Node

const SALES_TAX = .071

# these statuses are expected to be in order ending with the most complete state
enum PIZZA_STATUSES {
	ordered,
	prepped,
	baking,
	baked,
	cut,
	boxed,
	delivered,
}

enum RECEIPT_STATUSES {
	new,
	order_placed,
	baking,
	baked,
	prepped,
	fulfilled,
	refunded,
}

enum RECEIPT_LINE_ITEMS {
	size,
	topping,
	sauce,
	cheese,
	tax,
	timestamp,
	total,
	grandTotal,
}

enum PIZZA_SIZES {
	six,
	ten,
	twelve,
	fourteen,
}

enum TOPPINGS {
	mushrooms,
	onions,
	olives,
	chikun,
	basil,
	tomatoes,
	jalapeno,
	bananaPeppers,
	pepperoni,
	bellPeppers,
	spinach,
}

enum SAUCES {
	marinara,
	alfredo,
	bbq,
	none,
}

enum CHEESES {
	light,
	normal,
	heavy,
	none,
}

const PIZZA_BAKE_TIMES = {
	PIZZA_SIZES.six:  6,
	PIZZA_SIZES.ten: 9,
	PIZZA_SIZES.twelve: 11,
	PIZZA_SIZES.fourteen: 16,
}

enum ORDER_STATUSES {
	new,
	fulfilled,
}

var CUSTOMER_NAMES = ["Jensen", "Frank", "Lucille", "Hope", "Max", "Macy", "Cory", "Kelsey", "George", "Casey"]

enum PHONE_SIGNALS {
	ringing,
	busy,
	answered,
	hang_up,
}

	
var PRICES = {
	RECEIPT_LINE_ITEMS.topping: {
		TOPPINGS.mushrooms: .5,
		TOPPINGS.olives: .3,
		TOPPINGS.chikun: 1,
		TOPPINGS.basil: .2,
		TOPPINGS.tomatoes: .2,
		TOPPINGS.onions: .15,
	},
	RECEIPT_LINE_ITEMS.sauce: {
		SAUCES.alfredo: 1,
		SAUCES.marinara: .5,
		SAUCES.bbq: 1.3,
		SAUCES.none: 0,	
	},
	RECEIPT_LINE_ITEMS.cheese: {
		CHEESES.light: .75,
		CHEESES.normal: 1,
		CHEESES.heavy: 2,
		CHEESES.none: 0,
	},
	RECEIPT_LINE_ITEMS.size: {
		PIZZA_SIZES.six: 4,
		PIZZA_SIZES.ten: 7,
		PIZZA_SIZES.twelve: 10,
		PIZZA_SIZES.fourteen: 12,
	}
}

const INITIAL_POPULATION = 7900000000
const BIRTHS_PER_DAY = 385000 # believe it or not, these numbers are true to real life
