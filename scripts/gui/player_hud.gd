extends Control
@onready var player = get_parent().get_parent();

var dps_tick = 0;
var dealt_damage = 0;
const SELECTED_COLOR = Color(0.67, 0.31, 0, 0.75)
const UNSELECTED_COLOR = Color(0.43, 0.43, 0.43, 0.75)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Health/Bar.value = player.health;
	$Health/OverHeal.value = player.health;
	$Health/Number.text = str(player.health);
	$HotBar/Weapon0.texture = player.weapons[0].icon;
	$HotBar/Weapon1.texture = player.weapons[1].icon;
	$HotBar/Weapon2.texture = player.weapons[2].icon;
	match player.held_weapon:
		0:
			$HotBar/Slot0.set_color(SELECTED_COLOR);
			$HotBar/Slot1.set_color(UNSELECTED_COLOR);
			$HotBar/Slot2.set_color(UNSELECTED_COLOR);
		1:
			$HotBar/Slot0.set_color(UNSELECTED_COLOR);
			$HotBar/Slot1.set_color(SELECTED_COLOR);
			$HotBar/Slot2.set_color(UNSELECTED_COLOR);
		2:
			$HotBar/Slot0.set_color(UNSELECTED_COLOR);
			$HotBar/Slot1.set_color(UNSELECTED_COLOR);
			$HotBar/Slot2.set_color(SELECTED_COLOR);
	_weapon_cooldown();
	_track_dps();

func _weapon_cooldown():
	if player.weapon_use_time > 0:
		match player.held_weapon:
			0:
				$HotBar/Cooldown0.max_value = player.weapon_cool_down;
				$HotBar/Cooldown0.value = player.weapon_cool_down - player.weapon_use_time;
			1:
				$HotBar/Cooldown1.max_value = player.weapon_cool_down;
				$HotBar/Cooldown1.value = player.weapon_cool_down - player.weapon_use_time;
			2:
				$HotBar/Cooldown2.max_value = player.weapon_cool_down;
				$HotBar/Cooldown2.value = player.weapon_cool_down - player.weapon_use_time;
	else:
		match player.held_weapon:
			0:
				$HotBar/Cooldown0.value = 0;
			1:
				$HotBar/Cooldown1.value = 0;
			2:
				$HotBar/Cooldown2.value = 0;
func _create_damage_text(value, parent, type):
	#Create a new dmage text instance
	var damage_text = DamageText.new();
	#Set the value of the damage text to the amount the player is being healed
	damage_text.text = str(value);
	#Parent the damage text to the player.
	damage_text.target = parent;
	#Set the damage text to display as a heal.
	damage_text.type = type
	#Spawn the damage text.
	parent.add_child(damage_text)

func _track_dps(): 
	dps_tick += 1;
	if dps_tick >= 60:
		$DPS.text = "DPS:" + str(dealt_damage)
		dps_tick = 0;
		dealt_damage = 0;
