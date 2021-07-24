extends "res://_proj/_CGameSystem/Scripts/CardTable.gd"


#--------------------------- CONFIG ----------------------------#

func EXAMPLE_CFG():
	setup_draw_cfg = [ # How to draw cards during SETUP
		{ "amount":0, "area":"Hand" }, 
		{ "amount":0, "area":"Track" }, 
	]
	setup_draw_index = 0
	#
	phase_draw_cfg = [ # How to draw cards during the various phases of a round
		[# 0
			{ "amount":0, "area":"Hand" }, 
		],
		[# 1
			{ "amount":0, "area":"Track" }, 
		],
	]
	phase_draw_index = 0
	#
	phase = 0 	# Track the current phase (sub-round)


#---------------------------- SETUP -----------------------------#

func _ready():
	#
	EXAMPLE_CFG()
	
		

func reset():
	#
	.reset()
	#
	draw_pile_activation(false)  
	
	
func discard_area(area_):
	var cards_to_discard = area_.get_all_cards()
	#
	.discard_area(area_)
	#
	$Card_Areas/Discard.put(cards_to_discard)
	$Card_Areas/Discard/slots/Pile.reveal_top_card()



#---------------------------- CORE -----------------------------#

func start_round():
	Global.out("=== New round ===", 3)
	discard_area($Card_Areas/Hand) 	
	discard_area($Card_Areas/Track)
	#
	return .start_round()
	#

func end_round(): pass	

func next_setup_draw(args_):
	var drawpile = $Card_Areas/Draw/slots/DrawPile	# EXAMPLE
	if not validate_draw(
		drawpile, 	# EXAMPLE
		$Card_Areas/Discard/slots/Pile, 	# EXAMPLE
		setup_draw_cfg[setup_draw_index-1].area,
		args_[0]
	): return
		#
	if setup_draw_index < setup_draw_cfg.size():
		var cfg = setup_draw_cfg[setup_draw_index]
		setup_draw_index += 1
		drawpile.draw(cfg.amount, cfg.area)
		return
		#	
	SignalRelay.remove("draw_finished", self, "next_setup_draw")
	SignalRelay.add("draw_finished", self, "phase_draw_finished")
	phase = 0
	drawpile.current_target_name = drawpile.Default_Target_Area_Name
	pass_button_activation(true)
	$Card_Areas/Hand.activation(true)		# EXAMPLE
	draw_pile_activation(true)
	print("Setup done")
	
	
func next_phase():
	match phase:
	# EXAMPLES
		0: 
			print("game phase 0")
		1:
			print("game phase 1")
		_:
			print("this should not be reached!")
			return
	#
	.next_phase()
	#
	
func phase_draw_finished(args_=[0]):
	if not validate_draw(
		$Card_Areas/Draw/slots/DrawPile,	# EXAMPLE 
		$Card_Areas/Discard/slots/Pile, 	# EXAMPLE
		$Card_Areas/Draw/slots/DrawPile.current_target_name, # i.e. if draw is invalid then resume drawing to this area once issue is resolved
		args_[0]
	): return
	#
	if phase_draw_index == phase_draw_cfg[phase].size()-1:
		next_phase() # This was the last draw for this game phase -- move on
		return
		#
	phase_draw_index += 1
	var cfg = phase_draw_cfg[phase][phase_draw_index]
	$Card_Areas/Draw/slots/DrawPile.draw(cfg.amount, cfg.area)	# EXAMPLE
	

func draw_pile_activation(state_):	# EXAMPLE
	# Will Draw pile respond to user input?
	$Card_Areas/Draw.activation(state_) 	
	# Change look of pass-button and responsiveness to user input
	pass_button_activation(state_) 		
#
func pass_button_activation(state_):
	$pass_Button.disabled = !state_
	$pass_Button.modulate.a = 1.0 if state_ else 0.3
	
