extends CharacterBody2D
#Physics constants :D
const MAX_SPEED = 500;
const ACCEL = 40;
const DECCEL = 75;
const AIR_ACCEL = 25;
const AIR_DECCEL = 50;
const FALL_ACCEL = 10;
const FALL_SPEED = 1000;
const JUMP_SPEED = -750;
const JUMP_DECCEL_RATE = 15;
const FAST_JUMP_DECCEL_RATE = 50;
var direction = 1;
var jump_deccel = 0;
var current_accel = ACCEL
var current_deccel = DECCEL
#The different states the player can be in (only one at a time, the player can NOT be for example both jumping and falling at once)
var states = {
	idle = 0,
	running = 1,
	falling = 2,
	jumping = 3,
}
var state = states.idle;
#Runs every physics tick
func _physics_process(delta: float) -> void:
	#Gets the direction the player is attempting to move.
	direction = Input.get_axis("left", "right");
	#Changes acceleration value depending on if they're on the floor or in the air.
	if is_on_floor(): 
		current_accel = ACCEL;0
		current_deccel = DECCEL;
	else: 
		current_accel = AIR_ACCEL;
		current_deccel = AIR_DECCEL;
	#Checks if the player is trying to move at all.
	if direction != 0:
		#Moves them in that direction if they're under their max speed
		if (abs(velocity.x) < MAX_SPEED - current_accel) || (sign(velocity.x) != direction): velocity.x += current_accel*direction;
		elif abs(velocity.x) < MAX_SPEED: velocity.x = MAX_SPEED*direction;
	else:
		if abs(velocity.x) > current_deccel: velocity.x -= current_deccel*sign(velocity.x);
		else: velocity.x = 0;
	


	if !is_on_floor():
		if velocity.y < FALL_SPEED: velocity.y += FALL_ACCEL;
		
	if Input.is_action_pressed("jump") && is_on_floor():
		state = states.jumping;
	match state:
		states.jumping:
			velocity.y = JUMP_SPEED + jump_deccel
			if velocity.y >= 0: 
				state = states.idle;
				jump_deccel = 0;
			if Input.is_action_pressed("jump"):
				jump_deccel += JUMP_DECCEL_RATE;
			else:
				jump_deccel += FAST_JUMP_DECCEL_RATE;
	move_and_slide()
