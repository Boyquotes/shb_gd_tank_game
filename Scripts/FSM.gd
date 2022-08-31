extends Node

onready var dummy_state = get_node("Dummy")

var previous_state = null
var current_state = null

func _ready():
	current_state = dummy_state
	current_state.enter(self)
	pass
	
func update(delta):
	if current_state == null:
		return
		
	current_state.execute(delta)
	pass
	
func get_state(name):
	return get_node(name)
	pass
	
func get_current_state():
	return current_state
	
func get_current_state_name():
	if current_state != null:
		return current_state.name
	return null
	
func get_previous_state():
	return previous_state
	
func get_previous_state_name():
	if previous_state != null:
		return previous_state.name
	return null
	
func change_state(name):
	var st = get_state(name)
	
	if st == null:
		return
		
	previous_state = current_state
	current_state.exit()
	current_state = st
	current_state.enter(self)
	pass
	
func change_to_dummy_state():
	change_state("Dummy")
	pass
	
func reload_state():
	var curr_st_name = get_current_state_name()
	
	if curr_st_name == null:
		return
	
	change_to_dummy_state()
	change_state(curr_st_name)
	
func change_to_previous_state():
	var prev_st_name = get_previous_state_name()
	
	if prev_st_name == null:
		return
		
	change_state(prev_st_name)
	pass
