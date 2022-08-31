extends Control

export(Resource) var next_scene

func _ready():
	pass

func _on_Restart_pressed():
	get_tree().change_scene(next_scene.resource_path)
