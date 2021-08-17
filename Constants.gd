extends Node

enum PIZZA_STATUSES {
	ordered,
	prepped,
	baking,
	baked,
	cut,
	boxed,
	delivered,
}

enum PIZZA_SIZES {
	six,
	ten,
	twelve,
	fourteen,
}

const PIZZA_SIZE_LABELS = {
	PIZZA_SIZES.six: "6\"",
	PIZZA_SIZES.ten: "10\"",
	PIZZA_SIZES.twelve: "12\"",
	PIZZA_SIZES.fourteen: "14\"",
}

const PIZZA_BAKE_TIMES = {
	PIZZA_SIZES.six:  6,
	PIZZA_SIZES.ten: 9,
	PIZZA_SIZES.twelve: 11,
	PIZZA_SIZES.fourteen: 16,
}
