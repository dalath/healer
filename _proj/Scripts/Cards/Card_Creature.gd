extends "res://_proj/Scripts/Cards/Card_BASE.gd"


export (int) var MaxHealth
export (int) var Health

var label_health


func _init():
	Card_Type = "Creature"

func _ready():
	label_health = $content/BR/health
	on_reshuffle()
	
	
func on_reshuffle():
	Health = 1 + (randi() % 3)
	update_labels()
	

func incoming_heal(spellpower_):
	Health = clamp(Health + spellpower_, 0, MaxHealth)
	update_health_label()
	return true # Let spellcard know that it has been used up

func is_injured():
	return Health < MaxHealth


func update_labels():
	update_health_label()

func update_health_label():
	label_health.text = "%d /%d" % [Health, MaxHealth]
