extends Node2D


# What functions to run in SlotFunc.gd during various events -- <event> <func name>
export (Dictionary) var Behaviors = { 
	"start_of_round": String(), 
	"end_of_round": String(), 
	"intercept_card_func": String(),  
}


export (bool) var Reveal_On_Arrival		# If TRUE then hide cover
export (bool) var Start_of_Round_Clear

var In_Card_Area
var Lock = false
var card



#---------------------------- SETUP -----------------------------#

func _ready(): pass
#	
func reset():
	remove_card(card)
	Lock = false


func start_round():
	SlotFunc.Library[ Behaviors["start_of_round"] ].call_func(self)
	if Start_of_Round_Clear:
		remove_card(card)
#
func end_round():
	SlotFunc.Library[ Behaviors["end_of_round"] ].call_func(self)



#---------------------------- CORE -----------------------------#	
	
func put_card(card_):
	if card != null: return false	# Error: Slot not available
	card_.In_Card_Slot = self
	if Reveal_On_Arrival: 
		card_.cover.visible = false
	add_child(card_)
	card = card_
	if not In_Card_Area.name in card.Behaviors:
		card.Behaviors[In_Card_Area.name] = ""
	return true
#
func remove_card(card_=null):
	if card_ == null:
		if card == null: 
			return false 
		else:
			card_ = card
			#
	card_.In_Card_Slot = null
	remove_child(card_)
	card = null
	return true

	
func is_available():
	return card == null



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
	return false or SlotFunc.Library[ Behaviors["intercept_card_func"] ].call_func(self)



func after_card_func(_card_): pass

func _on_Timer_timeout(): pass 
