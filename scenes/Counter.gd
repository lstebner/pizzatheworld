extends Node2D

signal leave

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const ORDER_MESSAGE = "hi there... i'll take a 6 inch pizza, with marinara sauce, extra cheese, mushrooms, and ... . .. olives."


# Called when the node enters the scene tree for the first time.
func _ready():
	$LeaveButton.connect("pressed", self, "_on_leave_button_pressed")
	$NextCustomerButton.connect("pressed", self, "_on_next_customer_button_pressed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_leave_button_pressed():
	emit_signal("leave")

func _on_next_customer_button_pressed():
	$CustomerDialog.setMessage(ORDER_MESSAGE)
