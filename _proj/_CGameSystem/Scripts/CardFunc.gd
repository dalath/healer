extends Node


var Library: Dictionary



#---------------------------- SETUP -----------------------------#

func _ready(): 
	Library = Dictionary()
	#
	Library[""] = funcref(self, "dummy")
	Library["from_draw_pile_to_target"] = funcref(self, "from_draw_pile_to_target")
	Library["draw_to_hand"] = funcref(self, "draw_to_hand")
	Library["hand_to_inventory"] = funcref(self, "hand_to_inventory")
	Library["to_discard"] = funcref(self, "to_discard")
	
	#Library["cast_spell"] = funcref(self, "to_discard")
	


#---------------------------- LIBRARY -----------------------------#
	
func dummy(card_):
	if Global.Debug_Verbosity_Level > 4: print("This card has no Behavior for %s" % card_.In_Card_Slot.In_Card_Area.name)

func from_draw_pile_to_target(card_):
	var target = card_.In_Card_Slot.current_target_name
	if Global.CardAreas[target].available_slots_count() == 0:
		if Global.Debug_Verbosity_Level > 8: print("Target: '%s' has no available slots")
		return false
	card_.remove_self()
	Global.CardAreas[target].put([card_])
	return true


func to_hand(card_):
	if Global.CardAreas["Hand"].available_slots_count() == 0:
		if Global.Debug_Verbosity_Level > 8: print("hand full")
		return false
	card_.remove_self()
	Global.CardAreas["Hand"].put([card_])
	return true

func to_track(card_):
	if Global.CardAreas["Track"].available_slots_count() == 0:
		if Global.Debug_Verbosity_Level > 8: print("track full")
		return false
		#
	card_.remove_self()
	Global.CardAreas["Track"].put([card_])
	return true
	
	
func to_discard(card_):
	card_.remove_self()
	Global.CardAreas["Discard"].put([card_])
	return true
