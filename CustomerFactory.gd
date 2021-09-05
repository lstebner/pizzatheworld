extends Node

var rng = RandomNumberGenerator.new()
var customers = []

func _ready():
	rng.randomize()

func generate():
	var customer = Models.Customer.new()
	customer.hunger = rng.randi() % 80 + 20
	# set name
	customer.setName(Constants.CUSTOMER_NAMES[rng.randi() % Constants.CUSTOMER_NAMES.size()])
	# set hunger level
	customer.setFullnessLevel(100 + rng.randi() % 50 - 15)
	# set sleep schedule
	var bedtime = rng.randi() % 24
	var wakeup = (bedtime + rng.randi() % 5 + 3) % 24
	customer.setSleepHours(bedtime, wakeup)
	
	customers.append(customer)
	
	return customer
