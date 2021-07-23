extends Node2D


var container

func _ready():
	Global.CardGrid = self
	container = $_m_/_g_



func add_card(card_):
	container.add_child(card_)
	#card_.position = Vector2(0,0)
