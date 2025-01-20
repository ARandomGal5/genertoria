extends State
class_name PlayerJump
#The speed at which your jump starts when you press jump (negative because up is negative and down is positive in godot)
const JUMP_SPEED = -500;
#Added to your vertical velocity every frame when you're jumping.
const JUMP_DECCEL = 50;
var JumpLetGo = false;
func _enter():
	player.velocity.y = JUMP_SPEED;
	
func _physics_update():
	if !Input.is_action_pressed("jump"): JumpLetGo = true;
	if JumpLetGo == true:
		player.velocity.y += JUMP_DECCEL
	
func _exit():
	JumpLetGo = false;
