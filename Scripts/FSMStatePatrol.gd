# implementasi state patrol.

extends "res://Scripts/FSMState.gd"

# tergantung nilai yang diisi di inspector.
# secara default ally.
# ally, dalam project ini adalah player, dan jika ada, team nya.
# tank AI itu sendiri ada di group enemy dalam project ini.
export var target_group = "ally"

var timer : float = 0.0
var player = null
var my_fsm = null

func enter(fsm):
	#print(self.owner.name + " - " + "Patrol Enter")
	my_fsm = fsm
	
	# incar tank player
	var nds = get_tree().get_nodes_in_group(target_group)
	randomize()
	var rndsidx = rand_range(0, nds.size() - 1)
	player = nds[rndsidx]
	pass
	
func execute(delta):
	#print(self.owner.name + " - " + "Patrol Execute")
	# bidik player.
	owner.aim(player.transform.origin)
	timer += delta
	if timer >= 3:
		#owner.shoot()
		var distance_to_player = owner.transform.origin - player.transform.origin
		distance_to_player = distance_to_player.length()
		
		if player.is_moving() and distance_to_player < 5.0:
			# jika player bergerak dan cukup dekat, maka attack.
			my_fsm.change_state("Attack")
			pass
		else:
			# jika player tidak bergerak, jalan menuju posisi acak.
			var randpath = owner.request_random_path(-10.0, 10.0)
			#print(randpath)
			
		timer = 0.0
		
	pass
	
func exit():
	#print(self.owner.name + " - " + "Patrol Exit")
	pass
