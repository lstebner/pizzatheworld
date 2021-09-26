extends Node


func checkIfPizzasMatch(pizza1, pizza2):
	var isMatch = true
	
	if pizza1.size != pizza2.size:
		print("pizza sizes don't match")
		isMatch = false
	if pizza1.cheese != pizza2.cheese:
		print("pizza cheeses don't match")
		isMatch = false
	if pizza1.sauce != pizza2.sauce:
		print("pizza sauces don't match")
		isMatch = false
	if pizza1.toppings.size() != pizza2.toppings.size():
		print("pizza num toppings don't match")
		isMatch = false
	else:
		for topping in pizza1.toppings:
			isMatch = isMatch and pizza2.toppings.has(topping)
		
		if !isMatch:
			print("pizza toppings don't match")
			
	return isMatch
