extends Node



var Page: Dictionary



#---------------------------- SETUP -----------------------------#

func _ready(): 
	Page = Dictionary()
	#
	Page[""] = funcref(self, "dummy")
	Page["heal"] = funcref(self, "heal")
	


#---------------------------- PAGES -----------------------------#

func dummy(card_):
	print("dummy spell")

func heal(source_, target_):
	print("heal spell")
	return target_.incoming_heal(source_.Power)

