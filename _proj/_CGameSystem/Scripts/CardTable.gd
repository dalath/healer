extends Node2D

# ::: CardTable :::
#
# Controls the CardAreas, acting as hub for
# the flow of the game, round by round and
# then each turn duing a round.



#----------------- CONFIG --------------------------------------#
#
# How to draw cards during SETUP
var cfg_setup 
#
# How to draw cards at start of a new ROUND
var cfg_round
#
# How to draw cards during the separate turns of a round
var cfg_turn
#
#
var cfg_index = 0 	# Internal counter for the configs
var current_cfg 	# The active config (cfg_setup, cfg_round or cfg_turn)
#
var turn = 0 		# Current turn (sub-round)
#----------------------------------------------------#


#::: SLOT SELECTION :::# Array of CardSlots
#    Currently showing as selected
var selected_slots: Array 	
#
#::: RESHUFFLE CHECK :::# Cached callback function 
#    Pick up where we left off before a reshuffle
var reshuffle_callback = { "pile":null, "function":null, "args":[] }





#------------------ SETUP ---------------------------------------#

func _ready():
	Global.CardTable = self
	SignalRelay.add("game_over", 	self, 	"handle_game_over")
	SignalRelay.add("draw_ended", self, 	"next_cfg_step")
	# 
	# Give local CardAreas a link to this CardTable
	for a in $Card_Areas.get_children():
		a.CardTable = self
		#
	EXAMPLE_CFG() # Load the CFGs
#
#::: RESET :::# --> Just an empty table
func reset():
	SignalRelay.emit("reset")
	for area in $Card_Areas.get_children():
		area.reset()
		#
	setup()


#::: SETUP :::# --> Initial state of a game, before the first round starts
func setup():
	selected_slots = [] 
	current_cfg = cfg_setup
	cfg_index = 0
	#
	var cfg = current_cfg[cfg_index]
	cfg.from.draw(cfg.amount, cfg.to)# <-- ACTIVATE CFG PROCESS

#::: NEW ROUND :::# --> Initial state of a round, before the first turn starts
func init_round():
	selected_slots = [] 
	current_cfg = cfg_round
	cfg_index = 0
	#
	var cfg = current_cfg[cfg_index]
	cfg.from.draw(cfg.amount, cfg.to)# <-- ACTIVATE CFG PROCESS

#::: CFG STEP FINISHED :::#
func next_cfg_step(args_):
	var cfg = current_cfg[cfg_index]
	if not validate_draw(
		cfg.from, cfg.to, $Card_Areas/Discard/slots/Pile, args_[0]
	): return #--> Could not end this step. Will return later for new try.
	#
	cfg_index += 1
	if cfg_index >= current_cfg.size():
#		cfg.from.current_target_name = cfg.from.Default_Target_Area_Name
		cfg_done()
		return
		#	
	cfg = current_cfg[cfg_index]
	cfg.from.draw(cfg.amount, cfg.to)	
#
#: CFG DONE :#
func cfg_done():
	print("done")
	if current_cfg == cfg_setup:
		current_cfg = cfg_round
	elif current_cfg == cfg_round:
		current_cfg = current_cfg#cfg_turn # TODO: turn system currently not being used
		#
	cfg_index = 0
	

func new_round():
	SignalRelay.emit("start")
	return true
#
func end_of_round(): 
	pass	


func handle_game_over(result_): 
	pass



#------------------ CORE ---------------------------------------#

#::: SLOT SELECTION :::#
func slot_toggled(slot_, unique_=false):
	# Cache current selected slots...
	if slot_.get_node("select").visible:
		if unique_:
			# Only one selected slot at a time allowed
			for s in selected_slots:
				s.get_node("select").visible = false
				#
			selected_slots = []
			#
		selected_slots.append(slot_)
	#...and uncache them if they are deselected 
	elif slot_ in selected_slots:
		selected_slots.erase(slot_)


func discard_selected(_slot_):
	for s in selected_slots:
		s.discard()

#::: CARD ACTIVATION :::#
func intercept_card_func(_card_):
	#
	# Tell card that you have no objection so it can proceed
	return false 
	

#::: RESHUFFLE CHECK :::# 
func validate_draw(drawpile_, current_target_, discardpile_, overflow_=0):
	#
	if overflow_ == 0 and drawpile_.cards.size() != 0: 
		return true	 # ALL OK :: reshuffle not needed
		#
	# Cache callback data so that we know where to pick up after reshuffle 
	reshuffle_callback = {
		"pile": drawpile_,
		"function": funcref(drawpile_, "draw"),
		"args": [overflow_, current_target_]
	}
	# Debug...
	Global.out("%d cards waiting to be drawn" % overflow_, 4)
	if discardpile_.cards.size() < overflow_:
		Global.out("SERIOUS ERROR: discard doesn't have enough cards to re-stock draw pile", 0)
		return false
		#...stuff
	#
	# READY :: Initiate reshuffle
	discardpile_.send_all_cards_to(drawpile_)
	$reshuffle_Timer.start()
	Global.out("re-shuffling...", 2)


	
func next_turn():
	turn = (turn+1) % 2
	cfg_index = 0
#	draw_pile_activation(true)
	
	
	
#------------------ I/O ---------------------------------------#

func _on_reshuffle_Timer_timeout():
	reshuffle_callback["pile"].reveal_top_card()
	reshuffle_callback["function"].call_funcv(reshuffle_callback["args"])


func _on_next_Button_pressed():
	pass
#	print("Pass button pressed")
#	draw_pile_activation(false) # Just an example
#	cfg_index = -1






#--------------- DRAW CFG ------------------------------------#

func EXAMPLE_CFG():
	var drawpile = $Card_Areas/Draw/slots/DrawPile
	cfg_setup = [ 	# Amounts drawn during SETUP
		{ "amount":0, "from":drawpile, "to":null }, 
#		...
	]
	#
	cfg_round = [ 	# Amounts drawn at the beginning of a round
		{ "amount":0, "from":drawpile, "to":null }, 
#		...
	]
	#
	cfg_turn = [ 	# Amounts drawn during turns
		[					# 0
			{ "amount":1, "from":drawpile, "to":"Hand" }, 
#			...
		],
		[					# 1
#			... 
		],
	]
