extends Node2D

# These are used to look up what functions to run in CardFunc.gd -- <current area> <func name>
export (Dictionary) var Behaviors 

var cover: Sprite 	# Back of card
var In_Card_Slot	# The CardSlot this card is currently in



#---------------------------- SETUP -----------------------------#

func _ready():
	Behaviors["Draw"] = "from_draw_pile_to_target"
	cover = $Cover



#---------------------------- TOOLS -----------------------------#

func remove_self():
	In_Card_Slot.remove_card(self)



#---------------------------- MOUSE -----------------------------#

#::: CARD ACTIVATION :::#
func on_card_activation(): 
	# First check up the chain if Table, Area or Slot wants to intercept
	if In_Card_Slot.intercept_card_func(self): 
		return # This action was intercepted 
		#
	# READY :: 
	# Run func for this card when in this particular Table/Area
	var cardfunc_name = Behaviors[In_Card_Slot.In_Card_Area.name]
	CardFunc.Library[cardfunc_name].call_func(self)	
	#
	# Any mop-up that should happen
	In_Card_Slot.after_card_func(self) 
	#
#::: CARD ACTIVATION :::#


func _on_mouse_catcher_gui_input(event):
	match event.get_class():
		"InputEventMouseButton": if event.pressed: on_card_activation()
		"InputEventMouseMotion": pass
		_: Global.out("Card: no handler for %s" % event.get_class(), 8)


