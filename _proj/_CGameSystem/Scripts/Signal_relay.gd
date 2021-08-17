extends Node


# VERY IMPORTANT TO INCLUDE
signal start
signal reset
signal pause
signal draw_ended
signal game_over



#---------------------------- SETUP -----------------------------#

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS



#---------------------------- CORE -----------------------------#

func add(name_, object_, function_):
	if not self.is_connected(name_, object_, function_):
		self.connect(name_, object_, function_)
#
func remove(name_, object_, function_):
	if self.is_connected(name_, object_, function_):
		self.disconnect(name_, object_, function_)
#
#
func emit(signal_, args_=null):
	if Global.Debug_Verbosity_Level > 8: print("emit: %s" % signal_)
	if args_ == null:
		self.emit_signal(signal_)
	else:
		self.emit_signal(signal_, args_)



