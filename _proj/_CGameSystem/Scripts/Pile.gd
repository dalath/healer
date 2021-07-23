extends "res://_proj/_CGameSystem/Scripts/CardSlot.gd"


export (bool) var Keep_Top_Card_Visible = true


var cards: Array



#---------------------------- SETUP -----------------------------#

func _ready(): pass
#
func reset():
	remove_all_cards()
	
	
func start_round():
	if Start_of_Round_Clear:
		remove_all_cards()
#
func end_round(): pass



#---------------------------- CORE -----------------------------#

func put_card(card_, init_=false):
	card_.In_Card_Slot = self
	add_child(card_)
	card_.cover.visible = !Reveal_On_Arrival
	card_.visible = false
	if init_: return # STOP here if this is during setup
	if Keep_Top_Card_Visible:
		card_.visible = true
		if cards.size() > 0:
			cards[-1].visible = false
	if not In_Card_Area.name in card_.Behaviors:
		card_.Behaviors[In_Card_Area.name] = ""
	cards.append(card_)
#
func remove_card(card_=null):
	if card_ == null or cards.find_last(card_) == -1: return false
	#
	card_.In_Card_Slot = null
	remove_child(card_)
	cards.erase(card_)
	return true
#	
func remove_all_cards():
	for c in cards:
		c.In_Card_Slot = null
		remove_child(c)
	cards = Array()
#
func send_all_cards_to(pile_):
	var outgoing_cards = cards
	remove_all_cards()
	for c in outgoing_cards:
		pile_.put_card(c)
	
func reveal_top_card():
	if cards.size() == 0: 
		if Global.Debug_Verbosity_Level > 6: print("Pile %s in %s has no top card to reveal" % [name, In_Card_Area.name])
		return false
	elif cards.size() > 1:
		cards[-2].visible = false
	cards.back().visible = true
	return true
	

func is_available():
	return true
	

#---------------------------- I/O -----------------------------#

#func intercept_card_func(card_): pass)
#
#func after_card_func(card_): pass
