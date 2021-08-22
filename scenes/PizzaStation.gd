extends Node2D

signal leave

var receipts = Player.Shop.OpenOrders
var currentReceiptIndex = -1

var pizzaInProgress = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	resetPizzaInProgress() #initializes object properties
	
	var sizeButtons = get_tree().get_nodes_in_group("size_buttons")
	var sauceButtons = get_tree().get_nodes_in_group("sauce_buttons")
	var toppingsButtons = get_tree().get_nodes_in_group("toppings_buttons")
	var addCheeseButton = $Cheeses/HBoxContainer/AddCheeseButton
	var nextReceiptButton = $Receipt/VBoxContainer/HBoxContainer/NextReceipt
	var previousReceiptButton = $Receipt/VBoxContainer/HBoxContainer/PrevReceipt
	var completedReceiptButton = $Receipt/VBoxContainer/HBoxContainer/CompletedReceipt
	
	for button in sizeButtons:
		button.connect("pressed", self, "_on_size_button_pressed", [button])
	
	for button in sauceButtons:
		button.connect("pressed", self, "_on_sauce_button_pressed", [button])
	
	for button in toppingsButtons:
		button.connect("pressed", self, "_on_toppings_button_pressed", [button])
	
	addCheeseButton.connect("pressed", self, "_on_add_cheese_button_pressed")
	nextReceiptButton.connect("pressed", self, "incrementCurrentReceiptIndex")
	previousReceiptButton.connect("pressed", self, "decrementCurrentReceiptIndex")
	completedReceiptButton.connect("pressed", self, "markCurrentReceiptCompleted")
	
	$LeaveStation.connect("pressed", self, "_on_leave_station_pressed")
	$PizzaInProgress/CompleteButton.connect("pressed", self, "_on_complete_pizza_pressed")
	$DiscardPizzaInProgress.connect("pressed", self, "_on_discard_pizza_in_progress_pressed")
	
	$FlashMessageTimer.connect("timeout", self, "_on_flash_message_timer_timeout")

func isPizzaInProgressComplete():
	return pizzaInProgress.isComplete()

func resetPizzaInProgress():
	pizzaInProgress = Models.Pizza.new()

func displayFlashMessage(message):
	$FlashMessage.text = message;
	$FlashMessageTimer.start()
	
func incrementCurrentReceiptIndex():
	if currentReceiptIndex < 0 and receipts.size() == 0: return
	
	currentReceiptIndex += 1
	if currentReceiptIndex >= receipts.size():
		currentReceiptIndex -= receipts.size()
		
func decrementCurrentReceiptIndex():
	if currentReceiptIndex < 0: return
	
	currentReceiptIndex -= 1
	if currentReceiptIndex < 0:
		currentReceiptIndex += receipts.size()

func markCurrentReceiptCompleted():
	if currentReceiptIndex < 0: return
	
	receipts[currentReceiptIndex].changeStatus(Constants.RECEIPT_STATUSES.prepped)

func _on_leave_station_pressed():
	emit_signal("leave")
	
func _on_complete_pizza_pressed():
	if !isPizzaInProgressComplete():
		displayFlashMessage("the pizza is still incomplete!")
		return
	
	pizzaInProgress.status = Constants.PIZZA_STATUSES.prepped
	displayFlashMessage("sending pizza to oven")
	Player.Shop.Pizzas.append(pizzaInProgress)
	#receipts[currentReceiptIndex].items.append(pizzaInProgress)
	
	resetPizzaInProgress()

func _on_size_button_pressed(button):	
	var newSize = -1
	
	match button.name:
		"Six": newSize = Constants.PIZZA_SIZES.six
		"Ten": newSize = Constants.PIZZA_SIZES.ten
		"Twelve": newSize = Constants.PIZZA_SIZES.twelve
		"Fourteen": newSize = Constants.PIZZA_SIZES.fourteen
	
	pizzaInProgress.setSize(newSize)
		
	displayFlashMessage("%s size selected" % pizzaInProgress.sizeLabel)

func _on_sauce_button_pressed(button):
	if pizzaInProgress.size == -1:
		displayFlashMessage("can't add sauce until size is chosen")
		return
	elif pizzaInProgress.cheese != "":
		displayFlashMessage("can't add sauce after cheese is added")
		return
	elif pizzaInProgress.sauce != "":
		displayFlashMessage("sauce already added")
		return
		
	pizzaInProgress.sauce = button.name
	displayFlashMessage("%s sauce selected" % pizzaInProgress.sauce)

func _on_toppings_button_pressed(button):
	if pizzaInProgress.cheese == "":
		displayFlashMessage("can't add toppings until cheese is added")
		return
	
	var addingExtra = pizzaInProgress.toppings.has(button.name)
	pizzaInProgress.toppings.append(button.name)
	
	if addingExtra:
		displayFlashMessage("adding more %s" % button.name)
	else:
		displayFlashMessage("adding %s" % button.name)

func _on_add_cheese_button_pressed():
	if pizzaInProgress.sauce == "":
		displayFlashMessage("can't add cheese until sauce is chosen")
		return
	if pizzaInProgress.toppings.size() > 0:
		displayFlashMessage("can't add cheese after toppings are added")
		return
		
	if pizzaInProgress.cheese == "extra": return
	
	if pizzaInProgress.cheese == "regular":
		pizzaInProgress.cheese = "extra"
	elif pizzaInProgress.cheese == "light":
		pizzaInProgress.cheese = "regular"
	else:
		pizzaInProgress.cheese = "light"
	
	displayFlashMessage("using a %s amount of cheese" % pizzaInProgress.cheese)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pizzaInProgress.size > -1:
		$PizzaInProgress/RichTextLabel.text = "size: %s\nsauce: %s\ncheese: %s\ntoppings: %s" % [Constants.PIZZA_SIZE_LABELS[pizzaInProgress.size], pizzaInProgress.sauce, pizzaInProgress.cheese, PoolStringArray(pizzaInProgress.toppings).join(", ")]
	else:
		$PizzaInProgress/RichTextLabel.text = "select size to begin making a pizza"
		
	if currentReceiptIndex > -1:
		var currentReceipt = receipts[currentReceiptIndex]
		
		if currentReceipt and currentReceipt.pizza:
			var nowBakingString = ""
			var hasBeenMade = currentReceipt.items.size() > 0
			var isComplete = currentReceipt.status == Constants.RECEIPT_STATUSES.baked
			
			if currentReceipt.status == Constants.RECEIPT_STATUSES.baking:
				nowBakingString = "now baking"
			if hasBeenMade:
				nowBakingString += "\nMADE"
			if isComplete:
				nowBakingString += "- ready"
			nowBakingString += "\n%s" % Constants.RECEIPT_STATUSES.keys()[currentReceipt.status]
			$Receipt/VBoxContainer/RichTextLabel.text = nowBakingString + "\n" + currentReceipt.lineItemsString()

func _on_discard_pizza_in_progress_pressed():
	resetPizzaInProgress()

func _on_flash_message_timer_timeout():
	$FlashMessage.text = ""
