extends Node
##Base state class that all player stats inherit.
class_name State
#Gets the player node.
@onready var player = get_parent().get_parent();
func _physics_process(delta: float) -> void:
	#Checks if the player's current state is set to this one.
	if player.state == self:
		#If the player is just entering this state, run the enter function.
		if player.last_state != self:
			_enter();
		_physics_update();
	elif player.last_state == self:
		_exit();
func _process(delta: float) -> void:
	if player.state == self:
		_update();
func _enter():
	pass;
	
func _exit():
	pass;
	
func _physics_update():
	pass;
	
func _update():
	pass;
