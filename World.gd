extends Node


var timeSinceEpoch = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	timeSinceEpoch += delta

