extends Node2D

# ::: CardArea :::
#
# Controls a number of CardSlots.
#
# Often used as targets and handlers 
# for sending Cards around the table.



export (bool) var Start_As_Active = true

var CardTable
var active: bool
var slots: Array



#---------------------------- SETUP -----------------------------#

func _ready():
	Global.CardAreas[name] = self	# Register with Global
	#
	slots = $slots.get_children()
	for s in slots:
		s.In_Card_Area = self
		#
	SignalRelay.add("start", self, "start")
	SignalRelay.add("end", self, "end")


func reset():
	active = Start_As_Active
	for slot in slots:
		slot.reset()


func start():
	active = Start_As_Active
	

func end():
	pass

#---------------------------------------------------------------#


# ::: INCOMING CARDS :::
func put(cards_):
	#
	# For every card, look at the slots and if 
	# there is an available one -- put down the card
	for _i_ in range(cards_.size()):
		#
		# Work from the "back" (top of stack irl)	
		if put_card(cards_[-1]): 	
			cards_.pop_back() # Card was put down
			#
	# Send back whatever is still left, 
	# or more likely -- an empty array 
	return cards_ 
#
func put_card(card_):
	for s in slots:
		if s.is_available():
			s.put_card(card_)
			return true
			#
	return false
		
	
func get_all_cards():
	#
	# Go through the slots and look for any cards 
	var found_cards = Array()
	for s in slots:
		if s.card != null:
			found_cards.append(s.card)
			#
	return found_cards


func discard_all_cards():
	for c in get_all_cards():
		c.remove_self()
		

func available_slots_count():
	var count = 0
	for s in slots:
		count += 1 if s.is_available() else 0
	return count


func deselect_all():
	for s in slots:
		s.change_select(false)


#---------------------------- I/O -----------------------------#

#::: CARD ACTIVATION :::#
func intercept_card_func(card_):
	# If this CardArea has been deactivated 
	# it will block all interaction, and so 
	# card actions will count as intercepted
	if not active: 
		Global.out("%s (CardArea) intercepts card. Reason: area not active" % name, 10)
		return true 
	# 
	# Before Card gets released, 
	# check if Table wants to intercept
	return CardTable.intercept_card_func(card_)



