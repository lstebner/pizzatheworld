extends Node2D

signal leave

const DialogBubble = preload("res://scenes/DialogBubble.tscn")

var currentCustomerIndex = -1
var currentDialogIndex = -1
var orderDialog = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$LeaveButton.connect("pressed", self, "_on_leave_button_pressed")
	$AnswerPhone.connect("pressed", self, "_on_answer_phone_pressed")
	$POS.connect("receipt_finalized", self, "_on_pos_receipt_finalized")
	Player.Residents.generateResident()
	
func createDialogBubbleWithMessage(message):
	var dialog = DialogBubble.instance()
	$dialog/VBoxContainer.add_child(dialog)
	dialog.add_to_group("customer_dialog_bubbles")
	dialog.setMessage(message)
	dialog.connect("message_complete", self, "_on_dialog_message_complete")

func clearExistingDialogBubbles():
	var bubbles = get_tree().get_nodes_in_group("customer_dialog_bubbles")
	for b in bubbles:
		b.queue_free()

func _on_leave_button_pressed():
	emit_signal("leave")

func _on_answer_phone_pressed():
	# the way this method is working right now will evnetually change
	# currently, it generates a resident on request and they say an
	# order, but eventually residents will decide to call in on their
	# own and this will simply answer the line
	var customers = Player.Residents.residents

	clearExistingDialogBubbles()
	currentCustomerIndex += 1
	if currentCustomerIndex > customers.size() - 1:
		Player.Shop.generateResident()
	
	orderDialog = customers[currentCustomerIndex].dialogForOrder()
	currentDialogIndex = 0
	createDialogBubbleWithMessage(orderDialog[currentDialogIndex])

func _on_dialog_message_complete():
	currentDialogIndex += 1
	
	if currentDialogIndex < orderDialog.size():
		createDialogBubbleWithMessage(orderDialog[currentDialogIndex])

func _on_pos_receipt_finalized(receipt):
	var customer = Player.Residents.get(currentCustomerIndex)

	if !customer: return
	
	var pizza = customer.pizzaForOpenOrder
	customer.placeOrderWithReceipt(receipt, pizza)
