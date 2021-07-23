extends "res://_proj/_CGameSystem/Scripts/Stack.gd"


export (Array, PackedScene) var CardTypes
export (Array, int) var Amounts
export (int) var Draw_Size
export (String) var Default_Target_Area_Name 	# Assign a default area for sending cards to unless otherwise specified in for example CardFunc
export (bool) var Face_Up


var cards: Array
var cards_left_to_deal: int
var current_target_name: String



#---------------------------- SETUP -----------------------------#

func _ready():
	pass
#
func reset():
	remove_all_cards()
	add_default_cards()
	current_target_name = Default_Target_Area_Name
#	
func add_default_cards():
	cards = Array()
	for i in range(Amounts.size()):
		for c in range(Amounts[i]):
			cards.append(CardTypes[i].instance())
	cards.shuffle()
	for c in cards:
		put_card(c, true)
	reveal_top_card()
	
	
func start_round():
	if Start_of_Round_Clear:
		remove_all_cards()
	
func end_round():
	current_target_name = Default_Target_Area_Name



#---------------------------- CORE -----------------------------#

func deal(amount_=1, target_area_name_=Default_Target_Area_Name):
	current_target_name = target_area_name_
	if amount_ == 0 or cards.size() == 0: 
		SignalRelay.emit("draw_finished", [amount_])
		return
	cards_left_to_deal = amount_
	var top_card = cards[-1]
	remove_card(top_card)
	Global.CardAreas[target_area_name_].put([top_card])
	reveal_top_card()
	$Timer.start()
#
func _on_Timer_timeout():
	deal(cards_left_to_deal-1, current_target_name)
	
	
func put_card(card_, init_=false):
	card_.In_Card_Slot = self
	add_child(card_)
	card_.cover.visible = not Face_Up
	card_.visible = false
	if init_: return
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
		remove_child(c)
	cards = Array()
	
	
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

func intercept_card_func(card_):
	if In_Card_Area.intercept_card_func(card_): return true
	#
	if current_target_name != "" and Global.CardAreas[current_target_name].available_slots_count() < Draw_Size:
		if Global.Debug_Verbosity_Level > 6: print("target needs %d available slots" % Draw_Size)
		return true
	for i in range(Draw_Size):
		var behavior_applied = CardFunc.Library[ cards[-1].Behaviors[In_Card_Area.name] ].call_func(cards[-1])
		if not behavior_applied: return true
		if not reveal_top_card():
			if Global.Debug_Verbosity_Level > 4: print("pile empty")			
			return true
			#
	return true # True -> tell card to not do anything else
#
func after_card_func(card_):
	pass
