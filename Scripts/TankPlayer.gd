extends KinematicBody

# Variables
export var health = 10
export var acceleration : float = 50.0
export var gravity : float = -9.8
export var max_slope_degree : float = 70.0
export var max_speed : float = 5.0
export var rotation_speed_horizontal : float = 80.0
export var rotation_speed_vertical : float = 80.0
export var turret_rotation_speed_horizontal : float = 80.0
export var turret_rotation_speed_vertical : float = 80.0
export var wheel_rotation_speed : float = 5.0;

var vel : Vector3 = Vector3()
var temp_vel  : Vector3 = Vector3()
var temp_rot : float = 0.0
var wheel_rot_left : float = 0.0
var wheel_rot_right : float = 0.0

# onready Variables
export(NodePath) var health_hud_path
var health_hud = null

onready var tank_body = get_node("Body")
onready var turret_horizontal = get_node("Body/TurretBody")
onready var turret_vertical = get_node("Body/TurretBody/Muzzle")
onready var spawn = get_node("Body/TurretBody/Muzzle/Spawn")
onready var wheel_fl = get_node("Body/WheelFL")
onready var wheel_fr = get_node("Body/WheelFR")
onready var wheel_rl = get_node("Body/WheelRL")
onready var wheel_rr = get_node("Body/WheelRR")
onready var engine_audio = get_node("Engine")

export(Resource) var bullet
export(Resource) var exp_sound

signal player_dead

# Methods
func _ready():
	#print(get_path())
	#(rad2deg(global_transform.basis.get_euler().y))
	health_hud = get_node(health_hud_path)
	temp_rot = rad2deg(global_transform.basis.get_euler().y);
	if health_hud:
		health_hud.value = health
	
func _process(delta):
	wheel_fl.rotate_x(deg2rad(wheel_rot_left))
	wheel_rl.rotate_x(deg2rad(wheel_rot_left))
	
	wheel_fr.rotate_x(deg2rad(wheel_rot_right))
	wheel_rr.rotate_x(deg2rad(wheel_rot_right))
	
	engine_audio.pitch_scale = lerp(engine_audio.pitch_scale, 1.0 + (((abs(wheel_rot_left) + abs(wheel_rot_right))/ (2.0 * wheel_rotation_speed)) * 1.0), acceleration/5.0 * delta)
	#engine_audio.pitch_scale = 1.0 + (((abs(wheel_rot_left) + abs(wheel_rot_right))/ (2.0 * wheel_rotation_speed)) * 1.0)
	
func _physics_process(delta):
	update_reset()
	update_input(delta)
	update_movement(delta)
	pass
	
func is_moving():
	return vel.length() > 0
	pass
	
func update_reset():
	temp_vel.z = 0
	temp_vel.x = 0
	wheel_rot_left = 0
	wheel_rot_right = 0
	
func update_movement(delta):
	var floor_normal : Vector3 = get_floor_normal()
	var rot_at_normal : Quat = ftr_quat(Vector3.UP, floor_normal)
	if(floor_normal == Vector3.ZERO):
		floor_normal = Vector3.UP
	var rot_at_normal_multiply : Quat = Quat(floor_normal, deg2rad(temp_rot))
	rotation = (rot_at_normal_multiply * rot_at_normal).get_euler()
	
	if not is_on_floor():
		temp_vel.y += delta * gravity
		
	vel.x = lerp(vel.x, temp_vel.x, acceleration * delta)
	vel.z = lerp(vel.z, temp_vel.z, acceleration * delta)
	vel.y = temp_vel.y
	
	vel.y = move_and_slide(vel, Vector3.UP, true).y
	var kc = move_and_collide(Vector3.ZERO)
	if not kc == null:
		#print(kc.position)
		pass
		
func update_input(delta):
	if Input.is_action_pressed("move_forward"):
		var tgrav : float = temp_vel.y
		temp_vel = -transform.basis.z.normalized() * max_speed
		temp_vel.y = tgrav
		wheel_rot_left -= 1.0 * wheel_rotation_speed
		wheel_rot_right -= 1.0 * wheel_rotation_speed
	if Input.is_action_pressed("move_backward"):
		var tgrav : float = temp_vel.y
		temp_vel = transform.basis.z.normalized() * max_speed
		temp_vel.y = tgrav
		wheel_rot_left += 1.0 * wheel_rotation_speed
		wheel_rot_right += 1.0 * wheel_rotation_speed
	if Input.is_action_pressed("turn_left"):
		temp_rot += rotation_speed_horizontal * delta
		wheel_rot_left += 1.0 * wheel_rotation_speed
		wheel_rot_right -= 1.0 * wheel_rotation_speed
	if Input.is_action_pressed("turn_right"):
		temp_rot -= rotation_speed_horizontal * delta
		wheel_rot_left -= 1.0 * wheel_rotation_speed
		wheel_rot_right += 1.0 * wheel_rotation_speed
	if Input.is_action_pressed("turn_turret_left"):
		turret_horizontal.rotation_degrees.y += turret_rotation_speed_horizontal * delta
	if Input.is_action_pressed("turn_turret_right"):
		turret_horizontal.rotation_degrees.y -= turret_rotation_speed_horizontal * delta
	if Input.is_action_pressed("turn_turret_up"):
		turret_vertical.rotation_degrees.x += turret_rotation_speed_vertical * delta
	if Input.is_action_pressed("turn_turret_down"):
		turret_vertical.rotation_degrees.x -= turret_rotation_speed_vertical * delta 
	if Input.is_action_just_pressed("shoot"):
		var bullet_instance = bullet.instance()
		bullet_instance.global_transform = spawn.global_transform
		bullet_instance.target_group = "enemy"
		get_tree().get_root().add_child(bullet_instance)

func damage():
	health = health - 1
	
	if health_hud:
		health_hud.set_hud_value(health)
		
	if health <= 0:
		#print("ally is dead")
		
		var asp = AudioStreamPlayer3D.new()
		add_child(asp)
		asp.stream = load(exp_sound.resource_path)
		asp.unit_db = 13
		asp.play()
		
		yield(get_tree().create_timer(0.5),"timeout")
		queue_free()
		emit_signal("player_dead")
	
func ftr_quat(from, to):
	if(from.cross(to).normalized().length() != 1.0):
		return Quat.IDENTITY
		
	var result : Quat = Quat(from.cross(to).normalized(), from.angle_to(to))
	return result
