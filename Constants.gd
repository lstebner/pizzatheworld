extends Node

const SALES_TAX = .071

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
	total,
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
