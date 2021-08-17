extends Node2D



#---------------------------- SETUP -----------------------------#

func _ready():
	randomize()
	reset_table()
	SignalRelay.add("game_over", self, "handle_game_over")

func reset_table():
	$game_over.visible = false
	$CardTable.reset()

func reset_buttons():
	$start_Button.disabled = false



#---------------------------- CORE -----------------------------#	
	
func handle_game_over(_args_):
	$game_over.visible = true
	reset_buttons()



#---------------------------- I/O -----------------------------#
	
func _on_reset_Button_pressed():
	reset_table()
	reset_buttons()
	
	
func _on_start_Button_pressed():
	$CardTable.new_round()


