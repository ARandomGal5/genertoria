extends CharacterBody2D
class_name Player
#Physics constants :D
#The fastest you can run
const MAX_SPEED = 250;
#The grounded rate at which you accel while holding a direction
const ACCEL = 20;
#The grounded rate your speed falls to 0 when not holding a direction.
const DECCEL = 40;
#The airborne rate at which you accel while holding a direction
const AIR_ACCEL = 10;
#The airborne rate your speed falls to 0 when not holding a direction.
const AIR_DECCEL = 20;
#The rate your falling speed accelerates
const FALL_ACCEL = 25;
#The fastest you can fall.
const FALL_SPEED = 1000;

var state = null;
var last_state = null;
var QueueHurt = false;
var direction = 1;

const MAX_HEALTH = 100;
const MAX_OVERHEAL = 200;
const REGEN_TIME = 60;
const REGEN_WAIT = 120;
const OVERHEAL_DECAY_TIME = 30;
var health = MAX_HEALTH;
var regen_tick = 0;
var time_since_hurt = REGEN_WAIT;

var time_since_platform_fall = 5;

var held_weapon: int = 0;
var weapons: Array = [load("res://resources/weapons/test_gun.tres"), load("res://resources/weapons/test_sword.tres"), load("res://resources/weapons/test_sword.tres")]
var weapon_use_time = 0;
var weapon_cool_down = 0;

var melee_hitboxes: Array = [null, null, null, null, null]
var InMeleeCombo = false;
var swing_damage = 0;
var swing_heal = 0;
var swing_kill_heal = 0;
var swing_knock_back = 0;
var SwingCrit = false;

@onready var hud = $PlayerHud.get_child(0);
#Runs every physics tick
func _physics_process(delta: float) -> void:
	#Gets the direction the player is attempting to move.
	#Checks if the player is trying to move at all.
	#Don't let the player move or fall if they're taking damage.
	if state != $States/PlayerHurt:
		#If they're on the floor, use base acceleration values.
		if is_on_floor():
			_move(ACCEL, DECCEL, Input.get_axis("left", "right"));
		#If they're off the floor, use air acceleration values and cause them to fall (if they're not wall sliding)
		elif state != $States/PlayerWallSlide:
			_move(AIR_ACCEL, AIR_DECCEL, Input.get_axis("left", "right"));
			if velocity.y < FALL_SPEED: velocity.y += FALL_ACCEL;
			
	direction = sign(get_global_mouse_position().x - global_position.x)
	#Run state machine logic.
	state = _state_machine(state);
	
	#Fall through platforms if you're holding down.
	if Input.is_action_pressed("down"): 
		set_collision_mask_value(5, false);
		time_since_platform_fall = 0;
	#Wait 5 frames to become tangible to platforms again so just tapping down will always cause you to fall through platforms.
	elif time_since_platform_fall >= 5: set_collision_mask_value(5, true);
	if time_since_platform_fall < 5: time_since_platform_fall += 1;
	
	#Check if the player is trying to fire, check if either the weapon is full auto and they're holding left click, or tapping left click, if the weapon is not on cool down, and if they have enough energy to use it
	if (weapons[held_weapon].type != weapons[held_weapon].weapon_types.gun && Input.is_action_pressed("primary_fire") || Input.is_action_just_pressed("primary_fire")) && weapon_use_time == 0 && health > weapons[held_weapon].energy_use && InMeleeCombo == false: 
		if weapons[held_weapon].type != weapons[held_weapon].weapon_types.melee: _fire_weapon();
		else: 
			$MeleeFrameData.play(weapons[held_weapon].frame_data);
			weapon_use_time += 1;
			InMeleeCombo = true;
	#If they don't have enough energy to use it and the weapon is not on cool down, play the no energy sound.
	elif (weapons[held_weapon].type == weapons[held_weapon].weapon_types.auto_gun && Input.is_action_pressed("primary_fire") || Input.is_action_just_pressed("primary_fire")) && weapon_use_time == 0: 
		$Sounds/NoEnergy.play();
		weapon_use_time += 1;
	#Increment the cooldown timer every tick.
	if weapon_use_time > 0: weapon_use_time += 1;
	if weapon_use_time >= weapon_cool_down: weapon_use_time = 0;
	#Check if the player attempts to switch weapons.
	if weapon_use_time == 0: _switch_weapons();
	#Run health regeneration logic
	_health_regen();
	#Commit to player movement.
	move_and_slide()

#State machine logic.
func _state_machine(old_state) -> State:
	#Defaults to the player's current state
	var new_state = old_state;
	#Save the state the player was in before, to tell the state scripts to either run their enter or exit functions.
	last_state = old_state;
	#Check if the player is on the floor.
	if is_on_floor():
		#If the player is moving on the floor, set their state to running, otherwise set it to idle/standing
		if abs(velocity.x) > 0: new_state = $States/PlayerRun;
		else: new_state = $States/PlayerIdle;
		#If the player presses the jump button, change the state to jumping
		if Input.is_action_pressed("jump"): new_state = $States/PlayerJump
	#If the player is off the floor and is not jumping or their jump is starting to go down, set their state to falling.
	else:
		#"Is on wall" only is true if you're actively holding into a wall btw, idk why but it works for this.
		if is_on_wall() || old_state == $States/PlayerWallSlide:
			new_state = $States/PlayerWallSlide
		elif old_state != $States/PlayerJump || velocity.y > 0:
			new_state = $States/PlayerFall;
		if Input.is_action_just_pressed("jump") && old_state == $States/PlayerWallSlide: new_state = $States/PlayerJump

	#If the player has taken damage, set their state to hurt (ran at the very end so it override all other state checks)
	if QueueHurt == true:
		new_state = $States/PlayerHurt;
	#Return the state to set the player to.
	return new_state
	
func _move(accel, deccel, move_direction):
	if move_direction != 0 && (abs(velocity.x) < MAX_SPEED || !is_on_floor()):
		#Moves them in that direction if they're under their max speed
		if (abs(velocity.x) < MAX_SPEED - accel) || (sign(velocity.x) != move_direction): velocity.x += accel*move_direction;
		elif abs(velocity.x) < MAX_SPEED: velocity.x = MAX_SPEED*move_direction;
	else:
		if abs(velocity.x) > deccel: velocity.x -= deccel*sign(velocity.x);
		else: velocity.x = 0;

func _fire_weapon():
	#Subtract the weapon's health cost from the player.
	health -= weapons[held_weapon].energy_use;
	#Sets the time since the player's taken damage to 0, so the player doesn't instantly regen health.
	time_since_hurt = 0;
	#Spawn a new projectile.
	var projectile = weapons[held_weapon].projectile.instantiate();
	#Move the projectile on top of the player.
	projectile.global_position = global_position;
	#Tells the projectile that the player shot it.
	projectile.shooter = self;
	#Gives the projectile the current location of the mouse, so it can aim towards it.
	projectile.cursor = get_local_mouse_position();
	#Creates a random number between 1 and 100, if it's equal to the crit chance or smaller, register the fire as a crit (so a weapon with a 5% crit chance needs a 5 or lower to crit)
	var crit_check = randi_range(0, 100);
	if crit_check <= weapons[held_weapon].crit_chance: 
		projectile.crit = true;
		#Plays the crit sound so the player knows their shot is a crit.
		$Sounds/Crit.play();
	add_sibling(projectile)
	
	#Increment the wepaon use time by 1 so the cooldown is active.
	weapon_use_time += 1;
	#Create a new damage text on the player to show the damage they take from firing the weapon.
	if weapons[held_weapon].energy_use > 0:
		hud._create_damage_text(weapons[held_weapon].energy_use, self, 0)
	$Sounds/Weapon.set_stream(weapons[held_weapon].sound)
	$Sounds/Weapon.play();
	
func _switch_weapons():
	if Input.is_action_just_pressed("weapon1"): held_weapon = 0;
	if Input.is_action_just_pressed("weapon2"): held_weapon = 1;
	if Input.is_action_just_pressed("weapon3"): held_weapon = 2;
	
	if Input.is_action_just_released("next_weapon") && held_weapon < 2: held_weapon += 1;
	elif Input.is_action_just_released("next_weapon"): held_weapon = 0;
	if Input.is_action_just_released("previous_weapon") && held_weapon > 0: held_weapon -= 1;
	elif Input.is_action_just_released("previous_weapon"): held_weapon = 2;
	if InMeleeCombo == false: weapon_cool_down = weapons[held_weapon].use_time;
	
#Health regen (and overheal decay because it makes sense to include it in the same function as it is basically just regen in reverse)
func _health_regen():
	if health < MAX_HEALTH && time_since_hurt >= REGEN_WAIT:
		regen_tick += 1;
		if regen_tick >= REGEN_TIME:
			health += 1;
			regen_tick = 0;
			hud._create_damage_text(1, self, 1)
	elif health > MAX_HEALTH:
		regen_tick += 1;
		if regen_tick >= OVERHEAL_DECAY_TIME:
			health -= 1;
			regen_tick = 0;
			hud._create_damage_text(1, self, 0)
	elif time_since_hurt < REGEN_WAIT:
		time_since_hurt += 1;
		
func _on_hurt_box_body_entered(body: Node2D) -> void:
	QueueHurt = true;
	$States/PlayerHurt.hit_damage = body.damage;
	$States/PlayerHurt.knock_back = body.knock_back;
	
##Melee Frame Data functions
#Used to create a damaging hitbox.
func _spawn_melee_hitbox(size: Vector2, offset: Vector2, damage: int, heal: int, kill_heal: int, knockback: Vector2, energy_cost: int, id: int):
	var area = Area2D.new();
	var hitbox = CollisionShape2D.new();
	var shape = RectangleShape2D.new();
	shape.size = size;
	hitbox.shape = shape;
	area.position.x = offset.x*direction;
	area.position.y = offset.y;
	add_child(area)
	area.add_child(hitbox)
	melee_hitboxes[id] = area;
	area.set_collision_layer_value(0, false);
	area.set_collision_mask_value(0, false);
	area.set_collision_mask_value(3, true);
	area.set_collision_mask_value(5, false);
	area.connect("body_entered", _deal_melee_damage)
	
	swing_damage = damage;
	swing_heal = heal;
	swing_kill_heal = kill_heal;
	swing_knock_back = knockback;
	health -= energy_cost;
	if energy_cost > 0:
		hud._create_damage_text(energy_cost, self, 0)
	
func _delete_melee_hitbox(id: int):
	melee_hitboxes[id].queue_free();

func _reswing_check(energy_cost: int, cooldown: int):
	if !Input.is_action_pressed("primary_fire") || Input.is_action_just_pressed("primary_fire") || health <= energy_cost: 
		$MeleeFrameData.play("RESET")
		InMeleeCombo = false;
		if health <= energy_cost: $Sounds/NoEnergy.play();
	else:
		weapon_cool_down = cooldown;
		weapon_use_time = 1;
		var crit_chance = randi_range(0, 100);
		if crit_chance <= weapons[held_weapon].crit_chance:
			SwingCrit = true;
			$Sounds/Crit.play();
		
func _end_combo():
	$MeleeFrameData.play("RESET")
	InMeleeCombo = false;

func _deal_melee_damage(body):
	if body is CharacterBody2D:
		var damage = 0;
		var heal_amount = 0;
		if SwingCrit == true: 
			damage = swing_damage*2;
			if body.health - damage > 0: heal_amount = swing_heal*2;
			else: heal_amount = swing_kill_heal*2
		else: 
			damage = swing_damage;
			if body.health - damage > 0: heal_amount = swing_heal;
			else: heal_amount = swing_kill_heal
		body._take_damage(damage, self, heal_amount, swing_knock_back);
