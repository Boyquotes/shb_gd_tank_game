extends "res://Scripts/FSMState.gd"

export var target_group = "ally"
var player = null
var my_fsm = null
var timer : float = 0.0
	
func enter(fsm):
	#print(self.owner.name + " - " + "Attack Enter")
	my_fsm = fsm
	var nds = get_tree().get_nodes_in_group(target_group)
	randomize()
	var rndsidx = rand_range(0, nds.size() - 1)
	player = nds[rndsidx]
	if player:
		player = player.get_node("Body/TurretBody")
	owner.request_path(player.global_transform.origin)
	pass
	
func execute(delta):
	#print(self.owner.name + " - " + "Attack Execute")
	owner.aim(player.global_transform.origin)
	timer += delta
	if timer >= 1:
		owner.shoot()
		owner.request_path(player.global_transform.origin)
		timer = 0.0
	pass
	
func exit():
	#print(self.owner.name + " - " + "Attack Exit")
	pass
