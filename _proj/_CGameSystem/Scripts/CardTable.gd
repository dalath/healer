extends Node2D


#--------------------------- CONFIG ----------------------------#

var setup_draw_cfg # How to draw cards during SETUP
var setup_draw_index = 0
#
var phase_draw_cfg # How to draw cards during the various phases of a round
var phase_draw_index = 0
var phase = 0 	# Track the current phase (sub-round)



#-------------------------- VARIABLES ---------------------------#

# CardSlots that are currently showing as selected
var selected_slots: Array 	
# Cached callback function -- called if a drawpile gets reshuffled mid-action
var reshuffle_callback = { "pile":null, "function":null, "args":[] }





#---------------------------- SETUP -----------------------------#

func _ready():
	SignalRelay.add("reset", self, "reset")
	SignalRelay.add("game_over", self, "handle_game_over")
	for a in $Card_Areas.get_children():
		a.CardTable = self
		

func reset():
	selected_slots = [] 
	
	
func discard_area(area_):
	var cards_to_discard = area_.get_all_cards()
	for c in cards_to_discard:
		c.remove_self()



#---------------------------- CORE -----------------------------#

func validate_draw(drawpile_, discardpile_, current_target_, overflow_=0):
	if overflow_ == 0 and drawpile_.cards.size() != 0: return true
	#
	reshuffle_callback = {
		"pile": drawpile_,
		"function": funcref(drawpile_, "draw"),
		"args": [overflow_, current_target_]
	}
	Global.out("%d cards waiting to be drawn" % overflow_, 4)
	if discardpile_.cards.size() < overflow_:
		Global.out("SERIOUS ERROR: discard doesn't have enough cards to re-stock draw pile", 0)
		return false
		#
	discardpile_.send_all_cards_to(drawpile_)
	Global.out("re-shuffling...", 2)
	$reshuffle_Timer.start()


func handle_game_over(result_): pass


func start_round():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "CardSlots", "start_round")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "CardAreas", "start_round")
	#
	SignalRelay.remove("draw_finished", self, "phase_draw_finished")
	SignalRelay.add("draw_finished", self, "next_setup_draw")
	setup_draw_index = 0
	next_setup_draw([0])
	return true

func end_round(): pass	

func next_setup_draw(args_): pass
	
	
func next_phase():
	phase = (phase+1) % 2
	phase_draw_index = 0
	draw_pile_activation(true)
	
func phase_draw_finished(args_=[0]): pass
	
func draw_pile_activation(state_):pass	
#
func pass_button_activation(state_): pass
	
	
	
#---------------------------- I/O -----------------------------#

func slot_toggled(slot_):
	if slot_.get_node("select").visible:
		selected_slots.append(slot_)
	elif slot_ in selected_slots:
		selected_slots.erase(slot_)


func intercept_card_func(_card_):
	return false # Tell card that you have no objection so it can proceed
	

func _on_reshuffle_Timer_timeout():
	reshuffle_callback["pile"].reveal_top_card()
	reshuffle_callback["function"].call_funcv(reshuffle_callback["args"])


func _on_pass_Button_pressed():
	print("Pass button pressed")
	draw_pile_activation(false) # Just an example
	phase_draw_index = -1
	phase_draw_finished()

