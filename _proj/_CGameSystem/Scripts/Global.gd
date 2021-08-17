extends Node


var CardAreas: Dictionary
var Debug_Verbosity_Level = 12

var CardTable


#---------------------------- SETUP -----------------------------#

func _ready():
	CardAreas = Dictionary()
	
	
	
#---------------------------- TOOLS -----------------------------#

func out(text_, verbose_level_):
	if Global.Debug_Verbosity_Level > verbose_level_: 
		print(text_)
