# script ini mengatur arena permainan.

# extend dari Spatial.
extends Spatial

export var num_of_enemy = 1

func _ready():
	pass
			
func _on_TankPlayer_player_dead():
	# ketika player dead, ganti ke scene GameOver.tscn.
	get_tree().change_scene("res://Scenes/GameOver.tscn")

func _on_TankAI_ai_dead():
	# ketika tank AI dead, jika tank AI habis, ganti ke scene Win.tscn.
	num_of_enemy = num_of_enemy - 1;
	if num_of_enemy <= 0:
		get_tree().change_scene("res://Scenes/Win.tscn")
