extends "res://_proj/Scripts/Cards/Card_BASE.gd"

export (String) var Spell
export (int) var Power


func _init():
	 Card_Type = "Spell"
	

func use(target_=null):
	if SpellBook.Page[Spell].call_funcv([self, target_]):
		to_discard()
		return true
		#
	return false
