extends Spatial

export var num_of_enemy = 1

func _ready():
	pass
			
func _on_TankPlayer_player_dead():
	get_tree().change_scene("res://Scenes/GameOver.tscn")

func _on_TankAI_ai_dead():
	num_of_enemy = num_of_enemy - 1;
	if num_of_enemy <= 0:
		get_tree().change_scene("res://Scenes/Win.tscn")
