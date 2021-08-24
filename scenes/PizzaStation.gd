extends Node2D

signal leave

var receipts = Player.Shop.OpenOrders
var currentReceiptIndex = -1

var pizzaInProgress = null

# Called when the node enters the scene tree for the first time.
func _ready():
	createButtons()
	resetPizzaInProgress() #initializes object properties
	
	var addCheeseButton = $Cheeses/HBoxContainer/AddCheeseButton
	var noCheeseButton = $Cheeses/HBoxContainer/NoCheeseButton
	var nextReceiptButton = $Receipt/VBoxContainer/HBoxContainer/NextReceipt
	var previousReceiptButton = $Receipt/VBoxContainer/HBoxContainer/PrevReceipt
	var completedReceiptButton = $Receipt/VBoxContainer/HBoxContainer/CompletedReceipt
	
	addCheeseButton.connect("pressed", self, "_on_add_cheese_button_pressed")
	noCheeseButton.connect("pressed", self, "_on_no_cheese_button_pressed")
	nextReceiptButton.connect("pressed", self, "incrementCurrentReceiptIndex")
	previousReceiptButton.connect("pressed", self, "decrementCurrentReceiptIndex")
	completedReceiptButton.connect("pressed", self, "markCurrentReceiptCompleted")
	
	$LeaveStation.connect("pressed", self, "_on_leave_station_pressed")
	$PizzaInProgress/CompleteButton.connect("pressed", self, "_on_complete_pizza_pressed")
	$DiscardPizzaInProgress.connect("pressed", self, "_on_discard_pizza_in_progress_pressed")
	
	$FlashMessageTimer.connect("timeout", self, "_on_flash_message_timer_timeout")

func createButtons():
	var existingButtons = get_tree().get_nodes_in_group("pizza_station_buttons")
	for b in existingButtons:
		b.queue_free()
	
	for size in Constants.PIZZA_SIZES.values():
		var button = Button.new()
		button.add_to_group("pizza_station_buttons")
		button.text = Names.SIZES[size]
		button.connect("pressed", self, "_on_size_button_pressed", [size])
		$Pans/VBoxContainer.add_child(button)
	
	for topping in Constants.TOPPINGS.values():
		var button = Button.new()
		button.add_to_group("pizza_station_buttons")
		button.text = Names.TOPPINGS[topping]
		button.connect("pressed", self, "_on_topping_button_pressed", [topping])
		$Toppings/GridContainer.add_child(button)
		
	for sauce in Constants.SAUCES.values():
		var button = Button.new()
		button.add_to_group("pizza_station_buttons")
		button.text = Names.SAUCES[sauce]
		button.connect("pressed", self, "_on_sauce_button_pressed", [sauce])
		$Sauces/VBoxContainer.add_child(button)


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
	if !pizzaInProgress.isComplete():
		displayFlashMessage("the pizza is still incomplete!")
		return
	
	pizzaInProgress.changeStatus(Constants.PIZZA_STATUSES.prepped)
	displayFlashMessage("sending pizza to oven")
	Player.Shop.Pizzas.append(pizzaInProgress)
	#receipts[currentReceiptIndex].items.append(pizzaInProgress)
	
	resetPizzaInProgress()

func _on_size_button_pressed(newSize):	
	pizzaInProgress.setSize(newSize)
	displayFlashMessage("%s size selected" % pizzaInProgress.sizeLabel)

func _on_sauce_button_pressed(sauce):
	if !pizzaInProgress.isSizeSet():
		displayFlashMessage("can't add sauce until size is chosen")
		return
	elif pizzaInProgress.isCheeseSet():
		displayFlashMessage("can't add sauce after cheese is added")
		return
	elif pizzaInProgress.isSauceSet():
		displayFlashMessage("sauce already added")
		return
		
	pizzaInProgress.sauce = sauce
	displayFlashMessage("%s sauce selected" % Names.SAUCES[pizzaInProgress.sauce])

func _on_topping_button_pressed(topping):
	if !pizzaInProgress.isCheeseSet():
		displayFlashMessage("can't add toppings until cheese is added")
		return
	
	var addingExtra = pizzaInProgress.hasTopping(topping)
	var toppingName = Names.TOPPINGS[topping]
	pizzaInProgress.toppings.append(topping)
	
	if addingExtra:
		displayFlashMessage("adding more %s" % toppingName)
	else:
		displayFlashMessage("adding %s" % toppingName)

func _on_add_cheese_button_pressed():
	if !pizzaInProgress.isSauceSet():
		displayFlashMessage("can't add cheese until sauce is chosen")
		return
	elif pizzaInProgress.hasToppings():
		displayFlashMessage("can't add cheese after toppings are added")
		return
	elif pizzaInProgress.cheese == Constants.CHEESES.heavy: 
		displayFlashMessage("there's no room for any more cheese!")
		return
	
	pizzaInProgress.addCheese()
	
	displayFlashMessage("using a %s amount of cheese" % Names.CHEESES[pizzaInProgress.cheese])

func _on_no_cheese_button_pressed():
	if !pizzaInProgress.isSauceSet():
		displayFlashMessage("choose sauce first")
		return
	elif pizzaInProgress.hasToppings():
		displayFlashMessage("can't change cheese after toppings are added")
		return
	
	pizzaInProgress.setNoCheese()
	displayFlashMessage("no cheese")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pizzaInProgress.isSizeSet():
		$PizzaInProgress/RichTextLabel.text = pizzaInProgress.getDescriptionString()
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
