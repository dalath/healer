extends "res://_proj/_CGameSystem/Scripts/CardSlot.gd"

# ::: Pile :::
#
# Acts like a CardSlot that can 
# hold more than one card. 



export (bool) var Keep_Top_Card_Visible = true

var cards: Array





#------------------ SETUP ---------------------------------------#

func reset():
	remove_all_cards()
	
	
func start_round():
	if Start_of_Round_Clear:
		remove_all_cards()
#
func end_round(): pass



#---------------------------- CORE -----------------------------#
#: INCOMING CARD :#
func put_card(card_, init_=false):
	card_.In_Card_Slot = self
	card_.cover.visible = !Reveal_On_Arrival
	add_child(card_)
	if Keep_Top_Card_Visible:
		card_.visible = true
		if cards.size() > 0:
			cards[-1].visible = false
	if not In_Card_Area.name in card_.Behaviors:
		card_.Behaviors[In_Card_Area.name] = ""
	cards.append(card_)


func remove_card(card_=null):
	if card_ == null or cards.find_last(card_) == -1: return null
	#
	card_.In_Card_Slot = null
	remove_child(card_)
	cards.erase(card_)
	return card_
#	
func remove_all_cards():
	for c in cards:
		c.In_Card_Slot = null
		remove_child(c)
	cards = Array()
#
func discard():
	for c in cards:
		c.to_discard()

func send_all_cards_to(pile_, shuffle_=true):
	var outgoing_cards = cards
	#
	remove_all_cards()
	#
	if shuffle_:
		outgoing_cards.shuffle()
		#
	for c in outgoing_cards:
		if shuffle_:
			c.on_reshuffle()
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
	


#------------------ I/O ---------------------------------------#
# SLOT ACTIVATION #
func _on_mouse_catcher_gui_input(event_):
	match event_.get_class():
		"InputEventMouseButton": 
			if event_.pressed: 
				Global.out("Pile activated (%s)" % Intercept_Function, 10)
				SlotFunc.Library[Intercept_Function].call_func(self)
		"InputEventMouseMotion": pass
		_: Global.out("Slot: no handler for %s" % event_.get_class(), 8)
