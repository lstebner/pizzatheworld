extends Node2D


var customer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func setCustomer(c):
	customer = c
	

func _process(delta):
	if !customer: return
	
	var hungerValue = customer.hunger / customer.hungerFullLevel * 100
	
	$VBoxContainer/HBoxContainer/name.text = customer.name
	$VBoxContainer/HBoxContainer/currentState.text = Models.CUSTOMER_STATES.keys()[customer.currentState]
	$VBoxContainer/HBoxContainer/hunger.value = hungerValue
	$VBoxContainer/HBoxContainer/sleepHours.text = "%s-%s" % [customer.bedtimeHour, customer.wakeupHour]
