extends Node2D

enum locations {
	PizzaStation,
	Counter,
	Office,
	Ovens,
	Deliveries,
}

const Places = {
	locations.PizzaStation: null,
	locations.Ovens: null,
	locations.Counter: null,
	locations.Office: null,
	locations.Deliveries: null,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	Places[locations.PizzaStation] = $locations/PizzaStation
	Places[locations.Ovens] = $locations/Ovens
	Places[locations.Counter] = $locations/Counter
	Places[locations.Deliveries] = $locations/Deliveries
	
	for location in Places.values():
		if location:
			location.connect("leave", self, "_on_location_leave_requested", [location])
	
	$PizzaStationButton.connect("pressed", self, "_on_location_button_pressed", [locations.PizzaStation])
	$CounterButton.connect("pressed", self, "_on_location_button_pressed", [locations.Counter])
	$OfficeButton.connect("pressed", self, "_on_location_button_pressed", [locations.Office])
	$OvensButton.connect("pressed", self, "_on_location_button_pressed", [locations.Ovens])
	$DeliveriesButton.connect("pressed", self, "_on_location_button_pressed", [locations.Deliveries])

func _process(delta):
	var openOrdersString = ""
	
	for order in Player.Shop.OpenOrders:
		var orderString = ""
		var nowBakingString = ""
		var hasBeenMade = order.items.size() > 0
		var isComplete = order.status == Constants.RECEIPT_STATUSES.baked
		
		if order.status == Constants.RECEIPT_STATUSES.baking:
			nowBakingString = "now baking"
		if hasBeenMade:
			nowBakingString += "\nMADE"
		if isComplete:
			nowBakingString += "- ready"
		nowBakingString += "\n%s" % Constants.RECEIPT_STATUSES.keys()[order.status]
		openOrdersString += "\n------\n%s\n%s" % [nowBakingString, order.lineItemsString()]

	$OpenOrdersLabel.text = openOrdersString
		

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
			$locations/Ovens.refreshPizzasList()
			
	if Places[loc]:
		viewScreen(Places[loc])
			
func _on_location_leave_requested(_location):
	$CurrentSceneCamera.position = Vector2.ZERO

func viewScreen(screen):
	$CurrentSceneCamera.position = screen.position
