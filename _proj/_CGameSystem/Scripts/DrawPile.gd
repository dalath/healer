extends "res://_proj/_CGameSystem/Scripts/Pile.gd"


export (Array, PackedScene) var CardTypes
export (Array, int) var Amounts
export (int) var Draw_Size
export (String) var Default_Target_Area_Name 	# Assign a default area for sending cards to unless otherwise specified in for example CardFunc


var cards_left_to_draw: int
var current_target_name: String



#---------------------------- SETUP -----------------------------#

func _ready(): pass
#
func reset():
	add_default_cards()
	reveal_top_card()
	current_target_name = Default_Target_Area_Name
#	
func add_default_cards():
	for c in cards:
		remove_child(c)
		c.queue_free()
		#
	cards = Array()
	for i in range(Amounts.size()):
		for _c_ in range(Amounts[i]):
			cards.append(CardTypes[i].instance())
	cards.shuffle()
	for c in cards:
		put_card(c, true)
	
	
func start_round():
	if Start_of_Round_Clear:
		add_default_cards()
	
func end_round():
	current_target_name = Default_Target_Area_Name



#---------------------------- CORE -----------------------------#

func draw(amount_=1, target_area_name_=Default_Target_Area_Name):
	current_target_name = target_area_name_
	cards_left_to_draw = amount_
	if amount_ < 1:
		SignalRelay.emit("draw_finished", [amount_])
		return
	elif cards.size() == 0: 
		SignalRelay.emit("draw_finished", [amount_])
		return
	var top_card = cards[-1]
	remove_card(top_card)
	Global.CardAreas[target_area_name_].put([top_card])
	reveal_top_card()
	$Timer.start()
#
func _on_Timer_timeout():
	draw(cards_left_to_draw-1, current_target_name)
	

func is_available():
	return true
	

#---------------------------- I/O -----------------------------#

#::: CARD ACTIVATION :::#
func intercept_card_func(card_):
	# First continue up the chain to see if Table->Area wants to intercept
	if In_Card_Area.intercept_card_func(card_):
		return true  # This action was intercepted
		#
	# Clicking a card in a DrawPile works a bit different
	#
	# 1) Since the point of DrawPiles is to send out cards, there needs to be a check 
	# on wether the target areas have enough free slot to receive the cards.
	if current_target_name != "" and Global.CardAreas[current_target_name].available_slots_count() < Draw_Size:
		if Global.Debug_Verbosity_Level > 6: print("target needs %d available slots" % Draw_Size)
		return true
		#
	# 2) DrawPiles might be set to send out more than one card at a time. 
	# Card by card, we execute its CardFunc, and then reveal the next and so on
	for _i_ in range(Draw_Size):
		var cardfunc_name = cards[-1].Behaviors[In_Card_Area.name]
		var run = CardFunc.Library[cardfunc_name].call_func(cards[-1])
		if not run: 
			return true
			#
		if not reveal_top_card():
			if Global.Debug_Verbosity_Level > 4: print("pile empty")			
			return true
			#
	return true # True -> tell card to not do anything else
#
func after_card_func(_card_):
	pass
