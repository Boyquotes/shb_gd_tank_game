extends "res://Scripts/FSMState.gd"

export var target_group = "ally"
var timer : float = 0.0
var player = null
var my_fsm = null

func enter(fsm):
	#print(self.owner.name + " - " + "Patrol Enter")
	my_fsm = fsm
	
	var nds = get_tree().get_nodes_in_group(target_group)
	randomize()
	var rndsidx = rand_range(0, nds.size() - 1)
	player = nds[rndsidx]
	pass
	
func execute(delta):
	#print(self.owner.name + " - " + "Patrol Execute")
	owner.aim(player.transform.origin)
	timer += delta
	if timer >= 3:
		#owner.shoot()
		
		if player.is_moving():
			my_fsm.change_state("Attack")
			pass
		else:
			var randpath = owner.request_random_path(-10.0, 10.0)
			#print(randpath)
			
		timer = 0.0
		
	pass
	
func exit():
	#print(self.owner.name + " - " + "Patrol Exit")
	pass
