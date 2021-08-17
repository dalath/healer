extends "res://_proj/_CGameSystem/Scripts/CardTable.gd"


var drawpile
var actions_max = 2
var actions_count = 0
 

func _ready():
	drawpile = $Card_Areas/Draw/slots/DrawPile
	cfg_setup = [ # How to draw cards during SETUP
		{ "amount":3, "from":drawpile, "to":null }, 
	]
	#
	cfg_round = [
		{ "amount":0, "from":drawpile, "to":null }, 
	]
	cfg_turn = [ # How to draw cards during the various phases of a round
		[
			{ "amount":0, "from":drawpile, "to":null }, 
		],
	]



#: CFG DONE :#
func cfg_done():
	#
	.cfg_done()
	#
	draw_pile_activation(true)
	#
	#
func draw_pile_activation(state_):
	$Card_Areas/Draw.active = state_ 	# Will Draw pile respond to user input? 	
	next_button_activation(state_) 		# Change state of pass-button
	#
	#
func next_button_activation(state_):
	$next_Button.disabled = !state_
	$next_Button.modulate.a = 1.0 if state_ else 0.3


#: OVERRIDE :#
func setup():
	selected_slots = []
	var count = 0		
	for c in drawpile.cards:
		if c.Card_Type == "Spell":
			drawpile.remove_card(c)
			drawpile.put_card(c)
			count += 1
			if count == 2:
				break
	for c in drawpile.cards:
		if c.Card_Type == "Creature":
			drawpile.remove_card(c)
			drawpile.put_card(c)
			break
			#
	drawpile.reveal_top_card()
	actions_count = 9999
	.setup()	
	actions_count = actions_max
				#
			
			
func new_round():
	deselect_all()
	roll_track()
	#
	actions_count = 9999
	drawpile.draw(2, null)
	actions_count = actions_max
			
			
func roll_track():
	#: Roll track rightward :#
	var right_slot = $Card_Areas/Track.slots[-1]
	var out_card = right_slot.Card
	if out_card != null:
		if out_card.is_injured():
			SignalRelay.emit("game_over", false)
			return
			#
		Global.out("<3", 1)
		out_card.to_discard()
	for i in range($Card_Areas/Track.slots.size()-2, -1, -1):
		var left_slot = $Card_Areas/Track.slots[i]
		var left_card = left_slot.remove_card()
		if left_card != null:
			right_slot.put_card(left_card)
			#
		right_slot = left_slot
		
		
func out_of_actions():
	if actions_count < 1:
		Global.out("Out of action points for this round", 5)
		deselect_all()
		return true
		#
	return false
			
			
#::: SLOT SELECTION :::#
func slot_toggled(slot_, unique_=true):
	.slot_toggled(slot_, unique_) # Cache current selected slots
#
#
func play_selected_on(card_):
	if selected_slots.size() == 0:
		Global.out("No cards have been selected yet", 8)
		return
		#
	if out_of_actions(): return
	# TODO: allow more than 1 selected card
	if selected_slots[0].Card.use(card_):
		actions_count -= 1


func discard_selected(_slot_):
	if out_of_actions(): return
	#
	for s in selected_slots:
		s.discard()
		actions_count -= 1
	
		
func deselect_all():
	for a in $Card_Areas.get_children():
		a.deselect_all()



func _on_next_Button_pressed():
	._on_next_Button_pressed()
	#
	new_round()
