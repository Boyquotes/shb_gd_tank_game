extends Control

export var value = 10

onready var health_value = get_node("ColorRect/HealthValue")

func _ready():
	health_value.text = String(value)
	
func set_hud_value(arg):
	value = arg
	health_value.text = String(value)
