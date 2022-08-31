extends Camera


# Variables
export var distance_from_player : Vector3 = Vector3(10.0, 10.0, 0.0)

export(NodePath) var focused_player_path
var focused_player = null

# Methods
func _ready():
	focused_player = get_node(focused_player_path)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass
	
func _process(delta):
	look_at(focused_player.transform.origin, Vector3.UP)
	transform.origin = focused_player.transform.origin + distance_from_player
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass
