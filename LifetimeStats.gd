extends Node

var daysCompleted = 0
var pizzasDeliveredToday = 0
var pizzasDeliveredLifetime = 0
var currentPPR = 0
var mostPizzasDeliveredInOneDay = 0
var incomeToday = 0
var incomeLifetime = 0
var maxIncomeInOneDay = 0
var dailyRecordLog = []

enum objectKeys {
	pizzasDeliveredToday,
	pizzasDeliveredLifetime,
	currentPPR,
	incomeToday,
	incomeLifetime,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func updateForEndOfDay():
	daysCompleted += 1
	
	if incomeToday > maxIncomeInOneDay:
		maxIncomeInOneDay = incomeToday
	if pizzasDeliveredToday > mostPizzasDeliveredInOneDay:
		mostPizzasDeliveredInOneDay = pizzasDeliveredToday
	
	print(createDailyRecordEntry())
	dailyRecordLog.append(createDailyRecordEntry())
	
func createDailyRecordEntry():
	return {
		objectKeys.pizzasDeliveredToday: pizzasDeliveredToday,
		objectKeys.pizzasDeliveredLifetime: pizzasDeliveredLifetime,
		objectKeys.currentPPR: currentPPR,
		objectKeys.incomeToday: incomeToday,
		objectKeys.incomeLifetime: incomeLifetime,
	}
