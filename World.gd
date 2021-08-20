extends Node


var timeSinceEpoch = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(1)
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()

func _on_timer_timeout():
	timeSinceEpoch += 1

