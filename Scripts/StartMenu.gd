extends Control

export(Resource) var next_scene

func _ready():
	#print_debug("StartMenu")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Start_pressed():
	get_tree().change_scene(next_scene.resource_path)

func _on_Quit_pressed():
	get_tree().quit()
