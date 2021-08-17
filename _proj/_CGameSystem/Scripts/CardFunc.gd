extends Node


var Library: Dictionary



#---------------------------- SETUP -----------------------------#

func _ready(): 
	Library = Dictionary()
	#
	Library[""] = funcref(self, "dummy")
	Library["from_draw_pile_to_target"] = funcref(self, "from_draw_pile_to_target")
	Library["to_hand"] = funcref(self, "to_hand")
	Library["to_track"] = funcref(self, "to_track")
	Library["to_discard"] = funcref(self, "to_discard")
	Library["toggle_select"] = funcref(self, "toggle_select_for_cardslot")
	Library["play_selected_on"] = funcref(self, "play_selected_on")

#------------------------------------------------------------------#
	
func dummy(card_):
	if Global.Debug_Verbosity_Level > 4: print("This card has no Behavior for %s" % card_.In_Card_Slot.In_Card_Area.name)

#------------------------------------------------------------------#

func from_draw_pile_to_target(card_):
	var target = card_.In_Card_Slot.current_target_name
	if Global.CardAreas[target].available_slots_count() == 0:
		if Global.Debug_Verbosity_Level > 8: print("Target: '%s' has no available slots")
		return false
	card_.remove_self()
	Global.CardAreas[target].put([card_])
	return true

#------------------------------------------------------------------#

func to_hand(card_):
	if Global.CardTable.out_of_actions(): return true
	#
	if Global.CardAreas["Hand"].available_slots_count() == 0:
		Global.out("hand full", 8)
		return false
	card_.remove_self()
	Global.CardAreas["Hand"].put([card_])
	return true

#------------------------------------------------------------------#

func to_track(card_):
	if Global.CardTable.out_of_actions(): return true
	#
	var track = Global.CardAreas["Track"]
	if not track.slots[0].is_available():
		Global.out("track starting slot is busy", 4)
		return false
		#
	card_.remove_self()
	track.put([card_])
	return true
	
#------------------------------------------------------------------#
	
func to_discard(card_):
	card_.remove_self()
	Global.CardAreas["Discard"].put([card_])
	return true

#------------------------------------------------------------------#

func toggle_select_for_cardslot(card_):
	card_.In_Card_Slot.toggle_select()
	return true

#------------------------------------------------------------------#

func play_selected_on(card_):
	card_.In_Card_Slot.In_Card_Area.CardTable.play_selected_on(card_)	
	return true
	
#------------------------------------------------------------------#	
