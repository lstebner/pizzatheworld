extends Node

signal day_changed
signal year_changed

const SECONDS_IN_MINUTE = 1
const MINUTES_IN_HOUR = 8
const HOURS_IN_DAY = 24
const DAYS_IN_MONTH = 30
const MONTHS_IN_YEAR = 12

const DAYS_IN_YEAR = DAYS_IN_MONTH * MONTHS_IN_YEAR
const SECONDS_IN_HOUR = SECONDS_IN_MINUTE * MINUTES_IN_HOUR
const SECONDS_IN_DAY = SECONDS_IN_HOUR * HOURS_IN_DAY
const SECONDS_IN_MONTH = SECONDS_IN_DAY * DAYS_IN_MONTH
const SECONDS_IN_YEAR = DAYS_IN_YEAR * SECONDS_IN_DAY
const MINUTES_IN_DAY = MINUTES_IN_HOUR * HOURS_IN_DAY

var CustomerFactory = load("res://CustomerFactory.gd")

var timeSinceEpoch = 0
var timeIsFrozen = false

var currentDate = {
	"hour": 0,
	"minute": 0,
	"dayOfMonth": 0,
	"monthOfYear": 0,
	"year": 0,
	"ampm": "am",
}

var currentPopulation = Constants.INITIAL_POPULATION

var customerFactory = CustomerFactory.new()

func _ready():
	generateCustomers(5)

func _process(delta):
	if timeIsFrozen: return

	timeSinceEpoch += delta
	updateDate()
	
	for customer in customerFactory.customers:
		customer._update(delta)

func getCurrentTime():
	return timeSinceEpoch

func freezeTime():
	timeIsFrozen = true

func unfreezeTime():
	timeIsFrozen = false

func updateDate():
	var newDate = getDateFromEpochTime(timeSinceEpoch)
	
	if newDate.dayOfMonth != currentDate.dayOfMonth:
		currentPopulation += Constants.BIRTHS_PER_DAY
		emit_signal("day_changed")
	if newDate.year != currentDate.year:
		emit_signal("year_changed")
	
	currentDate = newDate

func getDateFromEpochTime(epochTime):
	var date = {
		"hour": 0,
		"minute": 0,
		"dayOfMonth": 0,
		"monthOfYear": 0,
		"year": 0,
		"ampm": "am",
	}
	var time = int(epochTime)

	if time == 0: return date

	var epochYears = floor(time / SECONDS_IN_YEAR)
	var epochMonths = floor(time / SECONDS_IN_MONTH)
	var epochDays = floor(time / SECONDS_IN_DAY)
	var epochHours = floor(time / SECONDS_IN_HOUR)
	var epochMinutes = floor(time / SECONDS_IN_MINUTE)

	date.year = 1 + epochYears
	date.monthOfYear = 1 + epochMonths - epochYears * MONTHS_IN_YEAR
	date.dayOfMonth = 1 + epochDays - epochMonths * DAYS_IN_MONTH
	date.hour = int(epochHours) % HOURS_IN_DAY
	date.minute = int(epochMinutes) % SECONDS_IN_HOUR * (60 / SECONDS_IN_HOUR) # minutes are adjusted to act like a 60 minute clock regardless of how many minutes per hour the game ticks
	
	if date.hour < HOURS_IN_DAY / 2:
		date.ampm = "am"
	else:
		date.ampm = "pm"

	return date
	
func formattedDateString():
	return "Day %s, Month %s, Year %s\n%s:%s%s" % [zeroPad(currentDate.dayOfMonth), zeroPad(currentDate.monthOfYear), zeroPad(currentDate.year), zeroPad(currentDate.hour), zeroPad(currentDate.minute), currentDate.ampm]

func formattedPopulation(populationValue):
	var string = str(populationValue)
	var mod = string.length() % 3
	var res = ""

	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]

	return res

func timestamp():
	return "%s/%s/%s %s:%s" % [currentDate.monthOfYear, currentDate.dayOfMonth, currentDate.year, currentDate.hour, currentDate.minute]

func zeroPad(num):
	if num < 10: return "0%s" % num
	return "%s" % num

	
func generateCustomers(amount):
	for i in amount:
		var customer = customerFactory.generate()
		customer.connect("call_pizza_shop", self, "_on_customer_call_pizza_shop", [customer])
		
func getCustomers():
	return customerFactory.customers
	
func getCustomer(idx):
	return customerFactory.customers[idx]
	
func _on_customer_call_pizza_shop(customer):
	var answered = Player.Shop.incomingCall(customer)
	
	if !answered:
		customer.callRejected()
