extends Node2D

signal insert_item
signal item_removed(item)
signal baking_complete

var item = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$ActionsContainer/Insert.connect("pressed", self, "_on_insert_pressed")
	$ActionsContainer/Remove.connect("pressed", self, "_on_remove_pressed")
	$ActionsContainer/CutPizza.connect("pressed", self, "_on_cut_pressed")
	$ActionsContainer/BoxPizza.connect("pressed", self, "_on_box_pressed")

	$BakeTimer.connect("timeout", self, "_on_bake_timer_timeout")

func insertItem(newItem):
	if item: return false
	
	item = newItem
	item.startBaking()
	$BakeTimer.set_wait_time(newItem.bakeTime)
	$BakeTimer.start()
	
	$ActionsContainer/Insert.hide()
	$ActionsContainer/Remove.show()
	
func removeItem(force = false):
	if !item.isBaked() and !force: return
	
	var removedItem = item
	item = null
	
	$ActionsContainer/Remove.hide()
	$ActionsContainer/Insert.show()
	
	return removedItem

func _process(delta):
	if item and item.status == Constants.PIZZA_STATUSES.baked:
		$LabelsContainer/TimeRemaining.text = "done!"
	else:
		$LabelsContainer/TimeRemaining.text = "%s" % round($BakeTimer.time_left)
	
	if item:
		$LabelsContainer/ItemName.text = "pizza"
	else:
		$LabelsContainer/ItemName.text = "<empty>"

func _on_insert_pressed():
	emit_signal("insert_item")

func _on_remove_pressed():
	if !item: return
	
	removeItem()
	emit_signal("item_removed", item)
	
func _on_cut_pressed():
	if !item: return
	
	print("cut item")
	item.cut()
	
func _on_box_pressed():
	if !item: return
	
	print("box item")
	item.box()
	
func _on_bake_timer_timeout():
	if !item: return
	
	item.completeBaking()
	emit_signal("baking_complete")
