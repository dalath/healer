extends "res://_proj/_CGameSystem/Scripts/Pile.gd"

# ::: DrawPile ::: 
#
# A Pile of cards to draw from.
# Usually has a Deck Config that 
# defines starting set of cards.
#
# --- NOTE ---
# Intercepts if top card gets clicked and tries to 
# execute CardFuncs on it but possibly on even more 
# cards, depending on Draw_Size.



#: Deck config :#
export (Array, PackedScene) var CardTypes
export (Array, int) var Amounts
#: Draw config :#
export (int) var Draw_Size
export (String) var Default_Target_Area_Name 	# Assign a default area for sending cards to unless otherwise specified in for example CardFunc
#-----------------------------------------------#
#: State cache :#
var cards_left_to_draw: int
var current_target_name: String



#---------------------------- SETUP -----------------------------#
#
func reset():
	add_default_cards()
	reveal_top_card()
	current_target_name = Default_Target_Area_Name


#: Deck config :#	
func add_default_cards():
	# Clear previous cards
	for c in cards:
		remove_child(c)
		c.queue_free()
		#
	#
	#: Fill pile :#
	cards = Array()
	for i in range(Amounts.size()):
		for _c_ in range(Amounts[i]):
			cards.append(CardTypes[i].instance())
			#
	cards.shuffle()
	#
	# Configure cards 
	for c in cards:
		c.In_Card_Slot = self
		c.cover.visible = !Reveal_On_Arrival
		c.visible = false
		add_child(c)
	
	
func start_round():
	if Start_of_Round_Clear:
		add_default_cards()
	
func end_round():
	current_target_name = Default_Target_Area_Name



#------------------ CORE ---------------------------------------#
#::: DRAW :::#
func draw(amount_=1, target_area_name_=Default_Target_Area_Name):
	#: CHECK :# If draw can proceed
	if amount_ < 1 or cards.size() == 0:
		current_target_name = Default_Target_Area_Name
		SignalRelay.emit("draw_ended", [amount_])
		return
		#
	# Progress counter
	cards_left_to_draw = amount_
	# 
	#: READY :#
	var top_card = cards[-1]
	if target_area_name_ != null:
		#: Simple draw :#
		remove_card(top_card)
		Global.CardAreas[target_area_name_].put([top_card])
		current_target_name = target_area_name_
	else:	
		#: Let card perform its specific CardFunc :#
		top_card.execute_card_func() #:: TAP ::#
		#
	reveal_top_card()
	$Timer.start() # Delay a bit between cards
	#
func _on_Timer_timeout():
	draw(cards_left_to_draw-1, null)
	
	
func tap():
	if cards.size() < 1: return
	#
	if cards[-1].execute_card_func():
		reveal_top_card()


#------------------ I/O ---------------------------------------#
#::: CARD ACTIVATION :::#
func intercept_card_func(card_):
	# First continue up the chain to see if Table->Area wants to intercept
	if In_Card_Area.intercept_card_func(card_):
		return true  # This action was intercepted
		#
	# DrawPiles might send out more than one card at a time
	# FOR CARDS BEING DRAWN --> execute CardFunc
	for _i_ in range(Draw_Size):
		#: CardFunc :#
		var cardfunc_name = cards[-1].Behaviors[In_Card_Area.name]
		var success = CardFunc.Library[cardfunc_name].call_func(cards[-1])
		# 
		if not success: #Validate operation
			Global.out("%s (DrawPile) could not activate %s (CardFunc)" % [name, cardfunc_name], 8)
			return true
			#
		#: DONE :#
		# Prepare the next card
		if not reveal_top_card():
			Global.out("pile empty", 8)			
			return true
			#
	return true






# TRASHCAN #
#__________#
# Clicking a card in a DrawPile works a bit different
	#
	# 1) Since the point of DrawPiles is to send out cards, 
	# there needs to be a check on wether the target areas 
	# have enough free slots to receive the cards.
#	if current_target_name != "" and Global.CardAreas[current_target_name].available_slots_count() < Draw_Size:
#		Global.out("Target needs %d available slots" % Draw_Size, 6)
#		return true
		#
	# 2) 
