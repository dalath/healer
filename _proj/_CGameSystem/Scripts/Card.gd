extends Node2D

# These are used to look up what functions to run in CardFunc.gd -- <current area> <func name>
export (Dictionary) var Behaviors = { 
	"Draw": "from_draw_pile_to_target", 
	"Discard": String(), 
	"hand_A": String(),  
	"hand_B": String(), 	
}

var cover: Sprite 	# Back of card
var In_Card_Slot	# The CardSlot this card is currently in



#---------------------------- SETUP -----------------------------#

func _ready():
	Behaviors["Draw"] = "from_draw_pile_to_target"
	cover = $Cover



#---------------------------- TOOLS -----------------------------#

func remove_self():
	In_Card_Slot.remove_card(self)



#---------------------------- I/O -----------------------------#

func _on_mouse_catcher_gui_input(event):
	match event.get_class():
		"InputEventMouseButton":
			if event.pressed: on_mouse_press()
		"InputEventMouseMotion":
			pass
		_: # DEFAULT
			if Global.Debug_Verbosity_Level > 8: print("Card: no handler for %s" % event.get_class())

func on_mouse_press():
	if In_Card_Slot.intercept_card_func(self): return 	# First check up the chain if card is supposed to handle this
	CardFunc.Library[ Behaviors[In_Card_Slot.In_Card_Area.name] ].call_func(self) 	# Activate card
	In_Card_Slot.after_card_func(self) 	# Maybe some mop-up?


