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

var currentPopulationDisplay = Constants.INITIAL_POPULATION

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

	Player.Shop.connect("phone_ringing", self, "_on_shop_phone_ringing")
	Player.Shop.connect("call_accepted", self, "_on_shop_phone_accepted")

func _process(delta):
	var openOrdersString = ""
	
	for order in Player.Shop.OpenOrders:
		var orderString = ""
		var nowBakingString = ""
		var hasBeenMade = false
		var isComplete = false #order.receipt.status == Constants.RECEIPT_STATUSES.baked
		
		if order.receipt.status == Constants.RECEIPT_STATUSES.baking:
			nowBakingString = "now baking"
		if hasBeenMade:
			nowBakingString += "\nMADE"
		if isComplete:
			nowBakingString += "- ready"
		nowBakingString += "\n%s" % Constants.RECEIPT_STATUSES.keys()[order.receipt.status]
		openOrdersString += "\n------\n%s\n%s" % [nowBakingString, order.receipt.lineItemsString()]

	if currentPopulationDisplay < GlobalWorld.currentPopulation:
		currentPopulationDisplay += round(Constants.BIRTHS_PER_DAY / GlobalWorld.MINUTES_IN_DAY * delta)
		
	$OpenOrdersLabel.text = openOrdersString
	$Balance.text = "$%s" % Player.Shop.Balance
	$WorldPopulation.text = "%s" % GlobalWorld.formattedPopulation(currentPopulationDisplay)
	$CurrentDate.text = "%s" % GlobalWorld.formattedDateString()
	$PizzasDelivered.text = "%s" % LifetimeStats.pizzasDeliveredLifetime
		

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
		locations.Deliveries:
			$locations/Deliveries.setupOrdersList()
			
	if Places[loc]:
		viewScreen(Places[loc])
			
func _on_location_leave_requested(_location):
	$CurrentSceneCamera.position = Vector2.ZERO

func viewScreen(screen):
	$CurrentSceneCamera.position = screen.position

func _on_shop_phone_ringing(_line):
	$PhoneIndicator.region_rect.position.x = 0
	
func _on_shop_phone_accepted(_line):
	$PhoneIndicator.region_rect.position.x = 48
