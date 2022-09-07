# implementasi dummy state.

extends "res://Scripts/FSMState.gd"

func enter(fsm):
	#print(self.owner.name + " - " + "Dummy Enter")
	pass
	
func execute(delta):
	#print(self.owner.name + " - " + "Dummy Execute")
	pass
	
func exit():
	#print(self.owner.name + " - " + "Dummy Exit")
	pass
