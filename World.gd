extends Node

const SECONDS_IN_MINUTE = 1
const MINUTES_IN_HOUR = 20
const HOURS_IN_DAY = 24
const DAYS_IN_MONTH = 30
const MONTHS_IN_YEAR = 12

const DAYS_IN_YEAR = DAYS_IN_MONTH * MONTHS_IN_YEAR
const SECONDS_IN_HOUR = SECONDS_IN_MINUTE * MINUTES_IN_HOUR
const SECONDS_IN_DAY = SECONDS_IN_HOUR * HOURS_IN_DAY
const SECONDS_IN_MONTH = SECONDS_IN_DAY * DAYS_IN_MONTH
const SECONDS_IN_YEAR = DAYS_IN_YEAR * SECONDS_IN_DAY

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

func _process(delta):
	if timeIsFrozen: return

	timeSinceEpoch += delta
	updateDate()

func freezeTime():
	timeIsFrozen = true

func unfreezeTime():
	timeIsFrozen = false

func updateDate():
	var time = int(timeSinceEpoch)
	if time == 0: return

	var epochYears = floor(time / SECONDS_IN_YEAR)
	var epochMonths = floor(time / SECONDS_IN_MONTH)
	var epochDays = floor(time / SECONDS_IN_DAY)
	var epochHours = floor(time / SECONDS_IN_HOUR)
	var epochMinutes = floor(time / SECONDS_IN_MINUTE)

	currentDate.year = 1 + epochYears
	currentDate.monthOfYear = 1 + epochMonths - epochYears * MONTHS_IN_YEAR
	currentDate.dayOfMonth = 1 + epochDays - epochMonths * DAYS_IN_MONTH
	currentDate.hour = int(epochHours) % HOURS_IN_DAY
	currentDate.minute = int(epochMinutes) % SECONDS_IN_HOUR * (60 / SECONDS_IN_HOUR) # minutes are adjusted to act like a 60 minute clock regardless of how many minutes per hour the game ticks
	
	if currentDate.hour < HOURS_IN_DAY / 2:
		currentDate.ampm = "am"
	else:
		currentDate.ampm = "pm"
	
func formattedDateString():
	return "Day %s, Month %s, Year %s\n%s:%s%s" % [zeroPad(currentDate.dayOfMonth), zeroPad(currentDate.monthOfYear), zeroPad(currentDate.year), zeroPad(currentDate.hour), zeroPad(currentDate.minute), currentDate.ampm]

func zeroPad(num):
	if num < 10: return "0%s" % num
	return "%s" % num
