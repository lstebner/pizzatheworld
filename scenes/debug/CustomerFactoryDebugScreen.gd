extends Node2D

var CustomerStatusBar = load("res://scenes/CustomerStatusBar.tscn")
var CustomerFactory = load("res://CustomerFactory.gd")


var factory = CustomerFactory.new()
var selectedCustomer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$GenerateCustomer.connect("pressed", self, "_on_generate_customer_pressed")
	$OrderPlaced.connect("pressed", self, "_on_order_placed_pressed")
	$DeliverPizza.connect("pressed", self, "_on_deliver_pizza_pressed")
	$CenterContainer/HBoxContainer/ItemList.connect("item_selected", self, "_on_customer_selected")

func _process(delta):
	$currentDate.text = GlobalWorld.formattedDateString()
	
	for c in factory.customers:
		c._update(delta)
	
	if selectedCustomer:
		renderCustomerLabel(selectedCustomer)

func refreshCustomersList():
	var itemList = $CenterContainer/HBoxContainer/ItemList
	itemList.clear()
	$CenterContainer/HBoxContainer/Label.text = ""
	
	for customer in factory.customers:
		var label = customer.name
		
		match customer.currentState:
			Models.CUSTOMER_STATES.placing_order:
				label += "  ###"
			Models.CUSTOMER_STATES.sleeping:
				label += "  zzZ"
			Models.CUSTOMER_STATES.eating:
				label += "  noms"
			
		itemList.add_item(label)

func _on_generate_customer_pressed():
	var newCustomer = factory.generate()
	selectedCustomer = null
	newCustomer.connect("call_pizza_shop", self, "_on_customer_status_changed")
	newCustomer.connect("full", self, "_on_customer_status_changed")
	newCustomer.connect("hungry", self, "_on_customer_status_changed")
	newCustomer.connect("wake_up", self, "_on_customer_status_changed")
	newCustomer.connect("go_to_sleep", self, "_on_customer_status_changed")
	newCustomer.connect("waiting", self, "_on_customer_status_changed")
	refreshCustomersList()

	
func _on_customer_selected(index):
	selectedCustomer = factory.customers[index]
	$CustomerStatusBar.show()
	$CustomerStatusBar.setCustomer(selectedCustomer)

func _on_order_placed_pressed():
	if !selectedCustomer: return
	selectedCustomer.setOpenOrder(Models.Order.new())
	selectedCustomer.waitForDelivery()
	
func _on_deliver_pizza_pressed():
	if !selectedCustomer: return
	selectedCustomer.fulfillOrder([Models.Pizza.new()])

func _on_customer_status_changed():
	refreshCustomersList()

func renderCustomerLabel(customer):
	var status = ""
	var stateKeys = Models.CUSTOMER_STATES.keys()
	
	status += "name: %s\n" % customer.name
	status += "current state: %s\n" % stateKeys[customer.currentState]
	status += "hunger: %s\n" % customer.hunger
	status += "sleep schedule: %s-%s\n" % [customer.bedtimeHour, customer.wakeupHour]
	
	$CenterContainer/HBoxContainer/Label.text = status
