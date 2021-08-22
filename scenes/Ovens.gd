extends Node2D

signal leave

var oven = Player.Shop.Ovens[0]
var itemSlots = []
var selectedPizza = null

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
	$PizzasList.connect("item_selected", self, "_on_pizzas_list_item_selected")
	
func refreshPizzasList():
	var selectedItems = $PizzasList.get_selected_items()
	$PizzaInfo.text = ""
	$PizzasList.clear()
	
	for pizza in Player.Shop.Pizzas:
		var bakedIndicator = "o"
		if pizza.isBaked():
			bakedIndicator = "x"
		elif pizza.isBaking():
			bakedIndicator = "-"
			
		if !pizza.isBoxed():
			$PizzasList.add_item(bakedIndicator + " " + pizza.getShortDescription())
	
	if selectedItems.size() > 0:
		$PizzasList.select(selectedItems[0])
		refreshPizzaInfo()

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

func refreshPizzaInfo():
	if selectedPizza:
		$PizzaInfo.text = selectedPizza.getDescriptionString()

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
	if oven.currentTemp == 0: return
	
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
	
	if selectedPizza:
		if selectedPizza.isBaked():
			print("this pizza is already baked, yo")
		elif selectedPizza.isBaking():
			print("this pizza is currently baking")
		else:
			slot.insertItem(selectedPizza)
			selectedPizza.startBaking()
			refreshPizzasList()
			#nextOrder.changeStatus(Constants.RECEIPT_STATUSES.baking) - TODO: turn this into a manual action
	else:
		print("select a pizza to bake")

func _on_item_slot_item_removed(removedItem):
	removedItem.completeBaking()
	refreshPizzasList()
	
	for order in Player.Shop.OpenOrders:
		if order.items.size() > 0:
			var orderIsComplete = true
			var orderIsBaked = true
			# todo: move this into a model method such as order.checkIfComplete()
			for item in order.items:
				orderIsBaked = orderIsBaked and item.isBaked()
				orderIsComplete = orderIsComplete and item.isBoxed()
			
			if orderIsComplete:
				order.changeStatus(Constants.RECEIPT_STATUSES.fulfilled)
			elif orderIsBaked:
				order.changeStatus(Constants.RECEIPT_STATUSES.baked)

func _on_item_slot_baking_complete(slot):
	pass

func _on_pizzas_list_item_selected(index):
	selectedPizza = Player.Shop.Pizzas[index]
	
	if selectedPizza:
		$PizzaInfo.text = selectedPizza.getDescriptionString()
	else:
		$PizzaInfo.text = ""

