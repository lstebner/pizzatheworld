extends Node2D

enum locations {
	PizzaStation,
	Counter,
	Office,
	Ovens,
}

const Places = {
	locations.PizzaStation: null,
	locations.Ovens: null,
	locations.Counter: null,
	locations.Office: null,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	Places[locations.PizzaStation] = $locations/PizzaStation
	Places[locations.Ovens] = $locations/Ovens
	
	for location in Places.values():
		if location:
			location.connect("leave", self, "_on_location_leave_requested", [location])
	
	$PizzaStationButton.connect("pressed", self, "_on_location_button_pressed", [locations.PizzaStation])
	$CounterButton.connect("pressed", self, "_on_location_button_pressed", [locations.Counter])
	$OfficeButton.connect("pressed", self, "_on_location_button_pressed", [locations.Office])
	$OvensButton.connect("pressed", self, "_on_location_button_pressed", [locations.Ovens])

func _on_location_button_pressed(loc):
	match loc:
		locations.PizzaStation:
			print("pizza pizza")
		locations.Office:
			print("the office")
		locations.Counter:
			print("be right there")
		locations.Ovens:
			print("checking ovens")
			
	if Places[loc]:
		viewScreen(Places[loc])
			
func _on_location_leave_requested(_location):
	$CurrentSceneCamera.position = Vector2.ZERO

func viewScreen(screen):
	$CurrentSceneCamera.position = screen.position
