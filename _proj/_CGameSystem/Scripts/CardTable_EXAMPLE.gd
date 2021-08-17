extends "res://_proj/_CGameSystem/Scripts/CardTable.gd"


#--------------------------- CONFIG ----------------------------#

func EXAMPLE_CFG():
	var drawpile = $Card_Areas/Draw/slots/DrawPile
	setup_draw_cfg = [ # How to draw cards during SETUP
		{ "amount":1, "from":drawpile, "to":"Hand" }, 
		{ "amount":1, "from":drawpile, "to":"Track" }, 
	]
	#
	step_draw_cfg = [ # How to draw cards during the various phases of a round
		[# 0
			{ "amount":1, "from":drawpile, "to":"Hand" }, 
		],
		[# 1
			{ "amount":3, "from":drawpile, "to":"Track" }, 
		],
	]
	#
	step = 0 	# Track the current round (sub) step


#---------------------------- SETUP -----------------------------#

func _ready():
	#
	EXAMPLE_CFG()
	._ready()
	
		
func new_round():
	Global.out("=== New round ===", 3)
	$Card_Areas/Hand.discard_all_cards()
	$Card_Areas/Track.discard_all_cards()
	draw_pile_activation(false)  
	return .new_round()


func end_round(): 
	pass	


#---------------------------- CORE -----------------------------#

func next_phase():
	match step:
	# EXAMPLES
		0: 
			print("round step 0")
		1:
			print("round step 1")
		_:
			print("this should not be reached!")
			return
	#
	.next_phase()
	

func draw_pile_activation(state_):	# EXAMPLE
	# Will Draw pile respond to user input?
	$Card_Areas/Draw.activation(state_) 	
	# Change look of pass-button and responsiveness to user input
	pass_button_activation(state_) 		
#
func pass_button_activation(state_):
	$pass_Button.disabled = !state_
	$pass_Button.modulate.a = 1.0 if state_ else 0.3
	
