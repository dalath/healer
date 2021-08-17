extends Node2D

# These are used to look up what functions to run in CardFunc.gd -- <current area> <func name>
export (Dictionary) var Behaviors 
export (String) var Discard_Area

var cover: Sprite 	# Back of card
var In_Card_Slot	# The CardSlot this card is currently in





#--------------------------------------------------------------#

func _init():
	cover = $Cover


#::: CARD ACTIVATION :::#
func on_card_activation(): 
	# First check up the chain if Table, Area or Slot wants to intercept
	if In_Card_Slot.intercept_card_func(self): 
		return # This action was intercepted 
		#
	#: READY :# 
	execute_card_func()
	#
func execute_card_func():
	# Run func for this card when in this particular Table/Area
	var cardfunc_name = Behaviors[In_Card_Slot.In_Card_Area.name]
	return CardFunc.Library[cardfunc_name].call_func(self)	


func on_reshuffle():
	pass

func to_discard(area_=Discard_Area):
	remove_self()
	Global.CardAreas[area_].put_card(self)
	
func remove_self():
	In_Card_Slot.remove_card(self)
	
	
	
#--------------------------------------------------------------#	

func _on_mouse_catcher_gui_input(event):
	match event.get_class():
		"InputEventMouseButton": 
			if event.pressed: 
				Global.out("Card activated (%s)" % Behaviors[In_Card_Slot.In_Card_Area.name], 10)
				on_card_activation()
		"InputEventMouseMotion": pass
		_: Global.out("Card: no handler for %s" % event.get_class(), 8)



