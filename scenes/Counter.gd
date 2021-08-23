extends Node2D

signal leave

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const ORDER_MESSAGE = "hi there... i'll take a 6 inch pizza, with marinara sauce, extra cheese, mushrooms, and ... . .. olives."

const DialogBubble = preload("res://scenes/DialogBubble.tscn")

var customers = []
var currentCustomerIndex = -1
var currentDialogIndex = -1
var orderDialog = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$LeaveButton.connect("pressed", self, "_on_leave_button_pressed")
	$NextCustomerButton.connect("pressed", self, "_on_next_customer_button_pressed")
	customers.append(Models.Customer.new())
	
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

func _on_next_customer_button_pressed():
	clearExistingDialogBubbles()
	currentCustomerIndex += 1
	if currentCustomerIndex > customers.size() - 1:
		customers.append(Models.Customer.new())
	
	orderDialog = customers[currentCustomerIndex].dialogForOrder()
	currentDialogIndex = 0
	createDialogBubbleWithMessage(orderDialog[currentDialogIndex])

func _on_dialog_message_complete():
	currentDialogIndex += 1
	
	if currentDialogIndex < orderDialog.size():
		createDialogBubbleWithMessage(orderDialog[currentDialogIndex])
