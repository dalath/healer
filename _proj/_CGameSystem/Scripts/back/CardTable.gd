extends Node2D


var reshuffle_callback = { "pile":null, "function":null, "args":[] }



#---------------------------- SETUP -----------------------------#

func _ready():
	for a in $Card_Areas.get_children():
		a.CardTable = self



#---------------------------- CORE -----------------------------#

func handle_overflow(pile_draw_, pile_discard_, amount_):
	if Global.Debug_Verbosity_Level > 4: print("%d cards waiting to be dealt" % amount_)
	if pile_discard_.cards.size() < amount_:
		if Global.Debug_Verbosity_Level > 0: print("SERIOUS ERROR: discard doesn't have enough cards to re-stock draw pile")
		return
		#
	pile_discard_.send_all_cards_to(pile_draw_)
	if Global.Debug_Verbosity_Level > 2: print("re-shuffling...")
	$reshuffle_Timer.start()



#---------------------------- I/O -----------------------------#

func intercept_card_func(_card_):
	return false # Tell card that you have no objection so it can proceed
	

func _on_reshuffle_Timer_timeout():
	reshuffle_callback["pile"].reveal_top_card()
	reshuffle_callback["function"].call_funcv(reshuffle_callback["args"])
