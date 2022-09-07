# script ini adalah FSM yang nantinya mengatur FSM state.

# extend dari Node.
extends Node

# start dalam state dummy.
onready var dummy_state = get_node("Dummy")

var previous_state = null
var current_state = null

func _ready():
	current_state = dummy_state
	current_state.enter(self)
	pass

# update state.
func update(delta):
	if current_state == null:
		return
		
	current_state.execute(delta)
	pass
	
# untuk mendapatkan state.
func get_state(name):
	return get_node(name)
	pass

# untuk mendapatkan state saat ini.
func get_current_state():
	return current_state

# untuk mendapatkan nama state saat ini.
func get_current_state_name():
	if current_state != null:
		return current_state.name
	return null

# untuk mendapatkan state sebelumnya.
func get_previous_state():
	return previous_state
	
# untuk mendapatkan nama state sebelumnya.
func get_previous_state_name():
	if previous_state != null:
		return previous_state.name
	return null

# untuk mengganti state.
func change_state(name):
	var st = get_state(name)
	
	if st == null:
		return
		
	previous_state = current_state
	current_state.exit()
	current_state = st
	current_state.enter(self)
	pass

# untuk ganti ke dummy state.
func change_to_dummy_state():
	change_state("Dummy")
	pass

# untuk me-reload state.
func reload_state():
	var curr_st_name = get_current_state_name()
	
	if curr_st_name == null:
		return
	
	change_to_dummy_state()
	change_state(curr_st_name)

# untuk mengganti state ke state sebelumnya.	
func change_to_previous_state():
	var prev_st_name = get_previous_state_name()
	
	if prev_st_name == null:
		return
		
	change_state(prev_st_name)
	pass
