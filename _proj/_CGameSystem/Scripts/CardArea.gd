extends Node2D


export (bool) var Start_As_Active = true

var CardTable
var active: bool
var slots: Array



#---------------------------- SETUP -----------------------------#

func _ready():
	Global.CardAreas[name] = self	# Register with Global
	activation(Start_As_Active)
#	SignalRelay.add("reset", self, "reset")
	#
	slots = $slots.get_children()
	for s in slots:
		s.In_Card_Area = self
#
func reset():
	activation(Start_As_Active)

func start_round():
	activation(Start_As_Active)
	
func end_round():
	pass
	


#---------------------------- CORE -----------------------------#

func put(cards_):
	for _i_ in range(cards_.size()): 	
		for s in slots:						# Find an available slot
			if s.is_available():
				s.put_card(cards_.pop_back()) # Work from the "back" (top of stack irl)
				break
	return cards_ # Send back overflow
#	
func get_all_cards():
	var found_cards = Array()
	for s in slots:
		if s.card != null:
			found_cards.append(s.card)
			#
	return found_cards

func available_slots_count():
	var count = 0
	for s in slots:
		count += 1 if s.is_available() else 0
	return count

func activation(state_):
	active = state_
			


#---------------------------- I/O -----------------------------#

func intercept_card_func(card_):
	if not active: return true # If not active, tell card to stop
	return CardTable.intercept_card_func(card_)
#
func after_card_func(_card_):
	pass
