# implementasi FSM State Attack.

# extend dari FSMState.
extends "res://Scripts/FSMState.gd"

# tergantung nilai yang diisi di inspector.
# secara default ally.
# ally, dalam project ini adalah player, dan jika ada, team nya.
# tank AI itu sendiri ada di group enemy dalam project ini.
export var target_group = "ally"

var player = null
var my_fsm = null
var timer : float = 0.0
	
func enter(fsm):
	#print(self.owner.name + " - " + "Attack Enter")
	my_fsm = fsm
	
	# incar tank player
	var nds = get_tree().get_nodes_in_group(target_group)
	randomize()
	var rndsidx = rand_range(0, nds.size() - 1)
	player = nds[rndsidx]
	if player:
		# targetkan Node TurretBody tank player.
		player = player.get_node("Body/TurretBody")
	
	# berjalan menuju tank player.
	owner.request_path(player.global_transform.origin)
	pass
	
func execute(delta):
	#print(self.owner.name + " - " + "Attack Execute")
	
	# bidik tank player.
	owner.aim(player.global_transform.origin)
	timer += delta
	if timer >= 1:
		# tembak tank player.
		owner.shoot()
		
		# terus mengejar tank player.
		owner.request_path(player.global_transform.origin)
		timer = 0.0
	pass
	
func exit():
	#print(self.owner.name + " - " + "Attack Exit")
	pass
