extends Node2D

# ::: CardSlot ::: 
#
# Can store a card. 
# Also has the ability to intercept a card's activation.



export (String) var Intercept_Function	# SlotFunc to run if a Card reports activation
export (bool) var Reveal_On_Arrival		# If TRUE then hide cover when moving
export (bool) var Start_of_Round_Clear

var Card
var In_Card_Area
var locked = false



#---------------------------- SETUP -----------------------------#

func _ready(): 
	SignalRelay.add("start", self, "start")
	SignalRelay.add("end", self, "end")


func reset():
	remove_card(self.Card)
	$select.visible = false
	self.locked = false


func end():
	pass	


func toggle_select():
	change_select(!$select.visible)
	
func change_select(state_):
	$select.visible = state_
	In_Card_Area.CardTable.slot_toggled(self)
	

#---------------------------------------------------------------#	



func is_available():
	return Card == null



#:: INCOMING CARD ::#
func put_card(card_):
	#
	# Check if there is already a card here
	if Card != null: 
		return false
		#
	# Register as the Card in this slot	
	Card = card_
	add_child(Card)
	Card.In_Card_Slot = self
	# Uncover if card should be face-up
	if Reveal_On_Arrival: 
		Card.cover.visible = false
		#
	# If card has no prepared reaction to our CardArea, assign a <dummy>
	if not In_Card_Area.name in Card.Behaviors:
		Card.Behaviors[In_Card_Area.name] = ""
		#
	return true
#
#
#:: OUTGOING CARD ::#
func remove_card(card_=null):
	#
	# Make sure there is any card to remove
	if card_ == null:
		if Card == null: 
			return null # NO CARD TO REMOVE
		else:
			card_ = Card
			#
	card_.In_Card_Slot = null
	remove_child(card_)
	Card = null
	$select.visible = false
	In_Card_Area.CardTable.slot_toggled(self) # Since $select is hidden, toggle will result in deselection
	return card_
#
func discard():
	Card.to_discard()



#---------------------------- I/O -----------------------------#

#::: CARD ACTIVATION :::#
func intercept_card_func(card_):
	# First continue up the chain to see if Table->Area wants to intercept
	if In_Card_Area.intercept_card_func(card_):
		return true  # This action was intercepted
		#
	# See if this Slot is specifically configured
	# to run its own function -- and if this function
	# will intercept and block card actions
	return false or SlotFunc.Library[Intercept_Function].call_func(self)


# SLOT ACTIVATION #
func _on_mouse_catcher_gui_input(event_):
	pass



# TRASHCAN #
#__________#
# What functions to run in SlotFunc.gd during various events -- <event> <func name>
# export (Dictionary) var Behaviors = { "start_of_round":"", "end_of_round":"", "intercept_card_func":"" }
#
