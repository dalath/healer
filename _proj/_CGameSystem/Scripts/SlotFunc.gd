extends Node


var Library: Dictionary



#---------------------------- SETUP -----------------------------#

func _ready(): 
	Library = Dictionary()
	#
	Library[""] = funcref(self, "dummy")
	Library["test"] = funcref(self, "test_func")
	Library["player_discard"] = funcref(self, "player_discard")
	Library["toggle_select"] = funcref(self, "toggle_select")
	


#---------------------------- LIBRARY -----------------------------#
	
func dummy(_slot_):
	return false#if Global.Debug_Verbosity_Level > 4: print("This slot has no Behavior for %s" % card_.In_Card_Slot.In_Card_Area.name)
	
func test_func(_slot_):
	print("testing SlotFunc")
	return false
	
	
func toggle_select(slot_):
	slot_.get_node("select").visible = !slot_.get_node("select").visible
	Global.CardTable.slot_toggled(slot_)
	return true
	
	
func player_discard(_slot_):
	Global.CardTable.player_discarded()
	return false
