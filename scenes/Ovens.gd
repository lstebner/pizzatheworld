extends Node2D

signal leave

var oven = Player.Shop.Ovens[0]
var itemSlots = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var powerOnButton = $temperature_controls/VBoxContainer/PowerOn
	var powerOffButton = $temperature_controls/VBoxContainer/PowerOff
	var increaseTempButton = $temperature_controls/VBoxContainer/HBoxContainer/IncreaseTemp
	var decreaseTempButton = $temperature_controls/VBoxContainer/HBoxContainer/DecreaseTemp
	
	itemSlots = [$CookBelt/pizza0, $CookBelt/pizza1, $CookBelt/pizza2, $CookBelt/pizza3]
	
	for slot in itemSlots:
		slot.connect("insert_item", self, "_on_item_slot_insert_item", [slot])
		slot.connect("item_removed", self, "_on_item_slot_item_removed")
		slot.connect("baking_complete", self, "_on_item_slot_baking_complete", [slot])
	
	$Leave.connect("pressed", self, "_on_leave_pressed")
	powerOnButton.connect("pressed", self, "_on_power_on_pressed")
	powerOffButton.connect("pressed", self, "_on_power_off_pressed")
	increaseTempButton.connect("pressed", self, "_on_increase_temp_button_pressed")
	decreaseTempButton.connect("pressed", self, "_on_decrease_temp_button_pressed")
	$ChangeTempTimer.connect("timeout", self, "_on_change_temp_timer_timeout")

func adjustTargetTemp(newTemp):
	oven.targetTemp = newTemp
	
	if oven.targetTemp <= oven.minTemp:
		oven.targetTemp = oven.minTemp
	elif oven.targetTemp > oven.maxTemp:
		oven.targetTemp = oven.maxTemp
		
	if oven.currentTemp != oven.targetTemp and !$ChangeTempTimer.time_left:
		$ChangeTempTimer.start()

func changeTemperature(amount):
	adjustTargetTemp(oven.targetTemp + amount)

func _process(delta):
	if oven.currentTemp != oven.targetTemp:
		$temperature_controls/VBoxContainer/CurrentTemp.text = "%sº->%sº" % [oven.currentTemp, oven.targetTemp]
	elif oven.turnedOn:
		$temperature_controls/VBoxContainer/CurrentTemp.text = "%sº" % oven.currentTemp
	else:
		$temperature_controls/VBoxContainer/CurrentTemp.text = "oven is off"

func _on_leave_pressed():
	emit_signal("leave")
	
func _on_power_on_pressed():
	oven.turnedOn = true

func _on_power_off_pressed():
	oven.turnedOn = false
	adjustTargetTemp(0)
	
func _on_increase_temp_button_pressed():
	changeTemperature(oven.tempControlStepAmount)

func _on_decrease_temp_button_pressed():
	changeTemperature(-oven.tempControlStepAmount)
	
func _on_change_temp_timer_timeout():
	if !oven.turnedOn and oven.currentTemp == 0: return
	
	if oven.targetTemp > oven.currentTemp:
		oven.currentTemp += 1
	elif oven.targetTemp < oven.currentTemp:
		oven.currentTemp -= 1
	else:
		$ChangeTempTimer.stop()
	
func _on_item_slot_insert_item(slot):
	if !oven.turnedOn: return print("oven isn't turned on!")
	if oven.currentTemp == 0: return print("oven temperature is not set")
	if oven.currentTemp < 700: return print("oven is still too cold")
	
	var nextOrder = null
	for order in Player.Shop.OpenOrders:
		if order.status == "order_placed":
			nextOrder = order
			break
	
	if nextOrder:
		if nextOrder.items.size() == 0:
			return print("this order does not have items available for the oven")
			
		slot.insertItem(nextOrder.items[0])
		nextOrder.status = "baking"
	else:
		print("no more orders need baking right now")

func _on_item_slot_item_removed(_removedItem):
	for order in Player.Shop.OpenOrders:
		if order.items.size() > 0:
			var orderIsComplete = true
			var orderIsBaked = true
			# todo: move this into a model method such as order.checkIfComplete()
			for item in order.items:
				print(item.status)
				orderIsBaked = orderIsBaked and item.isBaked()
				orderIsComplete = orderIsComplete and item.isBoxed()
			
			if orderIsComplete:
				order.status = "complete" # move to order.changeStatus, needs ORDER_STATUS constants
			elif orderIsBaked:
				order.status = "baked"

func _on_item_slot_baking_complete(slot):
	pass
