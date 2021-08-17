extends "res://_proj/_CGameSystem/Scripts/Card.gd"

var Card_Type



func _init():
	 Card_Type = "BASE"



func use(target_=null):
	In_Card_Slot.toggle_select()
	return false
	# TRUE -> used action point
