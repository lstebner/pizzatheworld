extends Node2D

signal leave

var openOrders = []
var pizzas = []
var selectedOrder = null
var selectedPizza = null

func _ready():
	$LeaveButton.connect("pressed", self, "_on_leave_button_pressed")
	$open_orders/HBoxContainer/ItemList.connect("item_selected", self, "_on_open_order_selected")
	$pizzas/HBoxContainer/ItemList.connect("item_selected", self, "_on_pizza_item_selected")
	$Fulfill.connect("pressed", self, "_on_fulfill_pressed")
	
func setupOrdersList():
	openOrders = Player.Shop.OpenOrders
	$open_orders/HBoxContainer/ItemList.clear()
	for order in openOrders:
		$open_orders/HBoxContainer/ItemList.add_item("order-%s" % order.receipt.id)
		
func setupPizzasList():
	pizzas = Player.Shop.Pizzas
	$pizzas/HBoxContainer/ItemList.clear()
	$pizzas/HBoxContainer/RichTextLabel.text = ""
	for pizza in pizzas:
		$pizzas/HBoxContainer/ItemList.add_item(pizza.id)
		
func fulfillSelectedOrder(pizza):
	selectedOrder.fulfill(pizza)
	updateSelectedOrderInfo()
	Player.Shop.Balance += selectedOrder.receipt.getTotalWithTax()
	
	selectedPizza = null
	$pizzas/HBoxContainer/ItemList.clear()
	
func updateSelectedOrderInfo():
	var selectedOrderString = ""
	
	selectedOrderString += "selected order: receipt-%s" % selectedOrder.receipt.id
	selectedOrderString += "\nfor %s" % selectedOrder.customerName
	if selectedOrder.fulfillmentPizza != null:
		selectedOrderString += "\nFULFILLED"
	selectedOrderString += "\n------------\n"
	selectedOrderString += "receipt:\n%s" % selectedOrder.receipt.lineItemsString()
	selectedOrderString += "\n------------\n"
	selectedOrderString += "desired pizza:\n%s" % selectedOrder.desiredPizza.getDescriptionString()
	
	$open_orders/HBoxContainer/RichTextLabel.text = selectedOrderString
		
func _on_leave_button_pressed():
	emit_signal("leave")

func _on_open_order_selected(index):
	selectedOrder = openOrders[index]
	
	setupPizzasList()
	updateSelectedOrderInfo()
	
func _on_pizza_item_selected(index):
	selectedPizza = pizzas[index]
	$pizzas/HBoxContainer/RichTextLabel.text = selectedPizza.getDescriptionString()

func _on_fulfill_pressed():
	if selectedOrder == null:
		print("no order selected to fulfill")
		return
	elif selectedPizza == null:
		print("no pizza to fulfill order with")
		return
		
	fulfillSelectedOrder(selectedPizza)
