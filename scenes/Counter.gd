extends Node2D

signal leave

const DialogBubble = preload("res://scenes/DialogBubble.tscn")

var currentCustomerIndex = -1
var currentDialogIndex = -1
var orderDialog = null
var ringingPhoneLine = null
var openPhoneLine = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$LeaveButton.connect("pressed", self, "_on_leave_button_pressed")
	$AnswerPhone.connect("pressed", self, "_on_answer_phone_pressed")
	$POS.connect("receipt_finalized", self, "_on_pos_receipt_finalized")
	Player.Shop.connect("phone_ringing", self, "_on_phone_ringing")
	Player.Shop.connect("call_accepted", self, "_on_phone_call_accepted")
	
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

func _on_phone_ringing(line):
	ringingPhoneLine = line
	$AnswerPhone.show()

func _on_answer_phone_pressed():
	if !ringingPhoneLine: return

	$AnswerPhone.hide()
	Player.Shop.answerPhone(0)

func _on_phone_call_accepted(line):
	orderDialog = line.customer.dialogForOrder()
	$dialog/NameOfCustomerOnPhone.text = "%s is on the line" % line.customer.name
	currentDialogIndex = 0
	createDialogBubbleWithMessage(orderDialog[currentDialogIndex])
	openPhoneLine = line

func _on_dialog_message_complete():
	currentDialogIndex += 1
	
	if currentDialogIndex < orderDialog.size():
		createDialogBubbleWithMessage(orderDialog[currentDialogIndex])

func _on_pos_receipt_finalized(receipt):
	var customer = openPhoneLine.customer # GlobalWorld.getCustomer(currentCustomerIndex)
	if !customer:
		print("can't find customer to finalize receipt")
		return
	
	var pizza = customer.pizzaForOpenOrder
	if !pizza:
		print("customer has no pizza open for order to use to finalize receipt")
		return
	
	var newOrder = Models.Order.new()
	
	newOrder.setDesiredPizza(pizza)
	newOrder.setReceipt(receipt)
	newOrder.setCustomerName(customer.name)

	Player.Shop.OpenOrders.append(newOrder)
	customer.setOpenOrder(newOrder)
	
	$dialog/NameOfCustomerOnPhone.text = ""
	clearExistingDialogBubbles()
	Player.Shop.hangUpPhoneLine(0)
