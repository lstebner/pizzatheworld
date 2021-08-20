extends Label


var currentLetterIndex = 0
var message = "hi there i'm a test message!"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect("timeout", self, "_on_timer_timeout")


func setMessage(newMessage):
	message = newMessage
	currentLetterIndex = 0
	self.text = ""
	$Timer.start()

func _on_timer_timeout():
	currentLetterIndex += 1
	self.text = message.substr(0, currentLetterIndex)
	
	if currentLetterIndex > message.length():
		$Timer.stop()
