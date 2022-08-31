extends RigidBody

export var target_group = "enemy"
export var speed :float = 100.0
export var lifetime: float = 0.8
export(Resource) var projectile_sound

func _ready():
	var asp = AudioStreamPlayer3D.new()
	add_child(asp)
	asp.stream = load(projectile_sound.resource_path)
	asp.unit_db = 13
	asp.play()
	
	linear_velocity = -global_transform.basis.z * speed
	yield(get_tree().create_timer(lifetime),"timeout")
	queue_free()

func _on_Bullet_body_entered(body):
	#print(body.get_groups())
	if body.get_groups().has(target_group):
		body.damage()
	
