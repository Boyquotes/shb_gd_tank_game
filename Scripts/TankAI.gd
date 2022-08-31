extends KinematicBody

# Variables
export var health = 10
export var acceleration : float = 50.0
export var gravity : float = -9.8
export var max_slope_degree : float = 70.0
export var max_speed : float = 5.0
export var checkpoint_distance = 5.0
export var rotation_speed_horizontal : float = 110.0
export var rotation_speed_vertical : float = 80.0
export var turret_rotation_speed_horizontal : float = 80.0
export var turret_rotation_speed_vertical : float = 80.0
export var wheel_rotation_speed : float = 5.0;
export var ray_length :float = 500.0
export var is_moving_forward : bool = true

var vel : Vector3 = Vector3()
var temp_vel  : Vector3 = Vector3()
var temp_rot : float = 0.0
var angle_between : float = 0.0
var wheel_rot_left : float = 0.0
var wheel_rot_right : float = 0.0
var path_nodes = []
var node_index = 0
var vertical_input_str = ""
var horizontal_input_str = ""

# onready Variables
export(NodePath) var nav_path
var nav = null

export(NodePath) var cam_path
var cam = null

export(NodePath) var debug_path
var debug = null

onready var fsm = get_node("FSM")
onready var engine_audio = get_node("Engine")
onready var tank_body = get_node("Body")
onready var turret_horizontal = get_node("Body/TurretBody")
onready var turret_vertical = get_node("Body/TurretBody/Muzzle")
onready var spawn = get_node("Body/TurretBody/Muzzle/Spawn")
onready var wheel_fl = get_node("Body/WheelFL")
onready var wheel_fr = get_node("Body/WheelFR")
onready var wheel_rl = get_node("Body/WheelRL")
onready var wheel_rr = get_node("Body/WheelRR")

export(Resource) var bullet
export(Resource) var exp_sound

signal ai_dead

# Methods
func _ready_instance():
	_ready()
	
func _ready():
	#(get_path())
	#print(rad2deg(global_transform.basis.get_euler().y))
	#print(nav_path)
	nav = get_node(nav_path)
	cam = get_node(cam_path)
	debug = get_node(debug_path)
	
	if nav == null:
		nav = get_parent()
	
	fsm.change_state("Patrol")
	temp_rot = rad2deg(global_transform.basis.get_euler().y);
	pass
	
func _process(delta):
	wheel_fl.rotate_x(deg2rad(wheel_rot_left))
	wheel_rl.rotate_x(deg2rad(wheel_rot_left))
	
	wheel_fr.rotate_x(deg2rad(wheel_rot_right))
	wheel_rr.rotate_x(deg2rad(wheel_rot_right))
	
	engine_audio.pitch_scale = lerp(engine_audio.pitch_scale, 1.0 + (((abs(wheel_rot_left) + abs(wheel_rot_right))/ (2.0 * wheel_rotation_speed)) * 1.0), acceleration/5.0 * delta)
	#engine_audio.pitch_scale = 1.0 + (((abs(wheel_rot_left) + abs(wheel_rot_right))/ (2.0 * wheel_rotation_speed)) * 1.0)
	pass
	
func _physics_process(delta):
	update_reset()
	update_game_logic(delta)
	update_path(delta)
	update_input(delta)
	update_movement(delta)
	pass
	
func _input(event):
	if cam == null:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var from = cam.project_ray_origin(event.position)
		var to = from + cam.project_ray_normal(event.position) * ray_length
		var result = get_world().direct_space_state.intersect_ray(from, to)
		
		#print(result)
		
		if not result.empty():
			is_moving_forward = true
			request_path(result["position"])
			# debug.global_transform.origin = result["position"]
			
	elif event is InputEventMouseButton and event.pressed and event.button_index == 2:
		var from = cam.project_ray_origin(event.position)
		var to = from + cam.project_ray_normal(event.position) * ray_length
		var result = get_world().direct_space_state.intersect_ray(from, to)
		
		#print(result)
		
		if not result.empty():
			is_moving_forward = false
			request_path(result["position"])
			debug.global_transform.origin = result["position"]
			
	pass
	
func update_reset():
	temp_vel.z = 0
	temp_vel.x = 0
	wheel_rot_left = 0
	wheel_rot_right = 0
	vertical_input_str = ""
	horizontal_input_str = ""
	pass
	
func update_game_logic(delta):
	fsm.update(delta)
	pass
	
func update_path(delta):
	var from = next_node()
	if from != null:
		var to = global_transform.origin
		var dir = from - to
		
		if dir.length() < checkpoint_distance:
			next_node_index()
		else:
			if is_moving_forward == false:
				angle_between = find_angle((transform.basis.z), dir)
				
				if angle_between < 0:
					horizontal_input_str = "turn_right"
				
				if angle_between > 0:
					horizontal_input_str = "turn_left"
					
				if abs(dir.z) > 0:
					vertical_input_str = "move_backward"
			elif is_moving_forward == true:
				angle_between = find_angle(-(transform.basis.z), dir)
				
				if angle_between < 0:
					horizontal_input_str = "turn_right"
				
				if angle_between > 0:
					horizontal_input_str = "turn_left"
				
				if abs(dir.z) > 0:
					vertical_input_str = "move_forward"
					pass
					
func update_movement(delta):
	var floor_normal : Vector3 = get_floor_normal()
	var rot_at_normal : Quat = ftr_quat(Vector3.UP, floor_normal)
	if(floor_normal == Vector3.ZERO):
		floor_normal = Vector3.UP
	var rot_at_normal_multiply : Quat = Quat(floor_normal, deg2rad(temp_rot))
	rotation = (rot_at_normal_multiply * rot_at_normal).get_euler()
	
	if not is_on_floor():
		temp_vel.y +=  gravity * delta
	
	vel.x = lerp(vel.x, temp_vel.x, acceleration * delta)
	vel.z = lerp(vel.z, temp_vel.z, acceleration * delta)
	vel.y = temp_vel.y

	vel.y = move_and_slide(vel, Vector3.UP, true).y
	
	var kc = move_and_collide(Vector3.ZERO)
	#if not kc == null:
	#	print(kc.position)
	#	pass
		
func update_input(delta):
	if vertical_input_str == "move_forward":
		var tgrav : float = temp_vel.y
		temp_vel = -transform.basis.z.normalized() * max_speed
		temp_vel.y = tgrav
		wheel_rot_left -= 1.0 * wheel_rotation_speed
		wheel_rot_right -= 1.0 * wheel_rotation_speed
		
	if vertical_input_str == "move_backward":
		var tgrav : float = temp_vel.y
		temp_vel = transform.basis.z.normalized() * max_speed
		temp_vel.y = tgrav
		wheel_rot_left += 1.0 * wheel_rotation_speed
		wheel_rot_right += 1.0 * wheel_rotation_speed
		
	if horizontal_input_str == "turn_left":
		temp_rot += rotation_speed_horizontal * delta
		wheel_rot_left += 1.0 * wheel_rotation_speed
		wheel_rot_right -= 1.0 * wheel_rotation_speed
		
	if horizontal_input_str == "turn_right":
		temp_rot -= rotation_speed_horizontal * delta
		wheel_rot_left -= 1.0 * wheel_rotation_speed
		wheel_rot_right += 1.0 * wheel_rotation_speed
		pass
		
func shoot():
	var bullet_instance = bullet.instance()
	bullet_instance.global_transform = spawn.global_transform
	bullet_instance.target_group = "ally"
	get_tree().get_root().add_child(bullet_instance)
	pass
	
func damage():
	health = health - 1
	if health <= 0:
		#print("enemy is dead")
		
		var asp = AudioStreamPlayer3D.new()
		add_child(asp)
		asp.stream = load(exp_sound.resource_path)
		asp.unit_db = 13
		asp.play()
		
		yield(get_tree().create_timer(0.5),"timeout")
		queue_free()
		
		emit_signal("ai_dead")
	
func aim(target_pos):
	turret_vertical.look_at(target_pos, Vector3.UP)
	var el = turret_vertical.transform.basis.get_euler()
	turret_horizontal.rotate_y(el.y)
	turret_vertical.rotate_x(el.x)
	pass
	
func request_path(target_pos):
	var from = global_transform.origin
	var to = target_pos
	path_nodes = nav.get_simple_path(from, to)
	reset_node_index()
	pass
	
func request_random_path(range_min, range_max):
	var ori = global_transform.origin
	var randx = rand_range(range_min, range_max)
	var randz = rand_range(range_min, range_max)
	var result = Vector3(ori.x + randx, ori.y, ori.z + randz)
	request_path(result)
	return result
	pass
	
func reset_node_index():
	node_index = 0
	pass
	
func next_node_index():
	node_index = node_index + 1
	pass
	
func next_node():
	if node_index < path_nodes.size():
		return path_nodes[node_index]
	else:
		return null
	pass
	
func find_angle(from, to):
	return from.angle_to(to) * (-1 if from.cross(to).y < 0 else 1)
	
func ftr_quat(from, to):
	if(from.cross(to).normalized().length() != 1.0):
		return Quat.IDENTITY
		
	var result : Quat = Quat(from.cross(to).normalized(), from.angle_to(to))
	return result
