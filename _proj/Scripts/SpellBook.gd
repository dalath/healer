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

func heal(card_):
	print("heal spell")
