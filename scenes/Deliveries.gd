extends Node2D

signal leave

func _ready():
	$LeaveButton.connect("pressed", self, "_on_leave_button_pressed")
	
func setupOrdersList():
	for customer in Player.Shop.OpenOrders:
		#$open_orders/ItemList.add_item(oder.id)
		pass
	
func _on_leave_button_pressed():
	emit_signal("leave")
