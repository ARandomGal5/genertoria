extends CharacterBody2D
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

var held_weapon: Weapon = load("res://resources/weapons/test_gun.tres")
var weapon_use_time = 0;

@onready var hud = $PlayerHud.get_child(0);
#Runs every physics tick
func _physics_process(delta: float) -> void:
	#Gets the direction the player is attempting to move.
	#Checks if the player is trying to move at all.
	if state != $States/PlayerHurt:
		if is_on_floor():
			_move(ACCEL, DECCEL, Input.get_axis("left", "right"));
		else:
			_move(AIR_ACCEL, AIR_DECCEL, Input.get_axis("left", "right"));
			if velocity.y < FALL_SPEED: velocity.y += FALL_ACCEL;
	state = _state_machine(state);
	if (held_weapon.full_auto == true && Input.is_action_pressed("primary_fire") || Input.is_action_just_pressed("primary_fire")) && weapon_use_time == 0 && health > held_weapon.energy_use: _fire_weapon();
	elif (held_weapon.full_auto == true && Input.is_action_pressed("primary_fire") || Input.is_action_just_pressed("primary_fire")) && weapon_use_time == 0: 
		$Sounds/NoEnergy.play();
		weapon_use_time += 1;
	if weapon_use_time > 0: weapon_use_time += 1;
	if weapon_use_time >= held_weapon.use_time: weapon_use_time = 0;
	_health_regen();
	move_and_slide()

func _state_machine(old_state) -> State:
	var new_state = old_state;
	last_state = old_state;
	if is_on_floor():
		if abs(velocity.x) > 0: new_state = $States/PlayerRun;
		else: new_state = $States/PlayerIdle;
		if Input.is_action_pressed("jump"):
			new_state = $States/PlayerJump
	else:
		if old_state != $States/PlayerJump || velocity.y > 0:
			new_state = $States/PlayerFall;
	if QueueHurt == true:
		new_state = $States/PlayerHurt;
	return new_state
	
func _move(accel, deccel, move_direction):
	if move_direction != 0:
		#Moves them in that direction if they're under their max speed
		if (abs(velocity.x) < MAX_SPEED - accel) || (sign(velocity.x) != move_direction): velocity.x += accel*move_direction;
		elif abs(velocity.x) < MAX_SPEED: velocity.x = MAX_SPEED*move_direction;
	else:
		if abs(velocity.x) > deccel: velocity.x -= deccel*sign(velocity.x);
		else: velocity.x = 0;
	if move_direction != 0: direction = move_direction;

func _fire_weapon():

	health -= held_weapon.energy_use;
	var projectile = Projectile.new();
	projectile.stats = held_weapon.projectile
	projectile.global_position = global_position;
	projectile.shooter = self;
	projectile.cursor = get_local_mouse_position();
	var crit_check = randi_range(0, 100);
	if crit_check <= held_weapon.crit_chance: 
		projectile.crit = true;
		$Sounds/Crit.play();
	var area = Area2D.new();
	area.set_collision_layer_value(0, false);
	area.set_collision_mask_value(3, true);
	var hitbox = CollisionShape2D.new();
	hitbox.shape = held_weapon.projectile.hit_box;
	projectile.add_child(area);
	area.add_child(hitbox);
	add_sibling(projectile)

	weapon_use_time += 1;
	var damage_text = DamageText.new();
	damage_text.text = str(held_weapon.energy_use);
	damage_text.target = self;
	add_child(damage_text)
	$Sounds/Weapon.set_stream(held_weapon.sound)
	$Sounds/Weapon.play();
	
func _health_regen():
	if health < MAX_HEALTH:
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
		
func _on_hurt_box_body_entered(body: Node2D) -> void:
	QueueHurt = true;
	$States/PlayerHurt.hit_damage = body.damage;
	$States/PlayerHurt.knock_back = body.knock_back;
	
