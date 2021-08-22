extends Node2D

var inputs = []
var receipt = null


func _ready():
	reset()
	createAllButtons()
	$actions/GridContainer/SubmitOrder.connect("pressed", self, "_on_submit_order_pressed")
	$actions/GridContainer/CancelOrder.connect("pressed", self, "_on_cancel_order_pressed")
	
func createAllButtons():
	for size in Constants.PIZZA_SIZES.values():
		var button = Button.new()
		button.text = Constants.PIZZA_SIZE_LABELS[size]
		button.connect("pressed", self, "_on_size_button_pressed", [size])
		$size/VBoxContainer/GridContainer.add_child(button)
	
	for topping in Constants.TOPPINGS.values():
		var button = Button.new()
		button.text = Constants.TOPPINGS.keys()[topping]
		button.connect("pressed", self, "_on_topping_button_pressed", [topping])
		$toppings/VBoxContainer/GridContainer.add_child(button)
		
	for sauce in Constants.SAUCES.values():
		var button = Button.new()
		button.text = Constants.SAUCES.keys()[sauce]
		button.connect("pressed", self, "_on_sauce_button_pressed", [sauce])
		$sauce/VBoxContainer/GridContainer.add_child(button)
		
	for cheese in Constants.CHEESES.values():
		var button = Button.new()
		button.text = Constants.CHEESES.keys()[cheese]
		button.connect("pressed", self, "_on_cheese_button_pressed", [cheese])
		$cheese/VBoxContainer/GridContainer.add_child(button)

func addInput(type, value):
	receipt.addLineItem(type, value)
	$receipt/RichTextLabel.text = receipt.lineItemsString()
	$HBoxContainer/Total.text = "TOTAL: %s" % receipt.getFormattedTotal()
	$HBoxContainer/Tax.text = "TAX: %s" % receipt.getFormattedTax()

func reset():
	inputs = []
	receipt = Models.Receipt.new()
	$receipt/RichTextLabel.text = ""
	$HBoxContainer/Total.text = "TOTAL"
	$HBoxContainer/Tax.text = "TAX"

func submitReceipt():
	receipt.finalize()
	Player.Shop.OpenOrders.append(receipt)
	reset()

func _on_size_button_pressed(size):
	addInput(Constants.RECEIPT_LINE_ITEMS.size, size)

func _on_topping_button_pressed(topping):
	addInput(Constants.RECEIPT_LINE_ITEMS.topping, topping)

func _on_sauce_button_pressed(sauce):
	addInput(Constants.RECEIPT_LINE_ITEMS.sauce, sauce)

func _on_cheese_button_pressed(cheese):
	addInput(Constants.RECEIPT_LINE_ITEMS.cheese, cheese)

func _on_submit_order_pressed():
	submitReceipt()

func _on_cancel_order_pressed():
	reset()
