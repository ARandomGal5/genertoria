extends Resource
class_name Weapon
##(For guns) the scene path to the projectile node to fire.
@export var projectile: PackedScene = null;
##(For swords) The name to reference when retrieving the frame data animation.
@export var frame_data: StringName;
##What type of weapon this is
@export var type: weapon_types = 0;
##The percent chance that this weapon will deal a crit (2x damage)
@export var crit_chance: int = 0;
##(For guns) How long the 'cooldown' for this weapon is (how long before you can perform another action, for swords use the cooldown value in the spawn hitbox function)
@export var use_time: int = 30;
##The amount of health the player loses when using this weapon.
@export var energy_use: int = 0;
##The icon displayed in the player's inventory.
@export var icon: Texture2D = null;
##The sound this weapon plays when used.
@export var sound: AudioStream = null;
enum weapon_types {
	##Fires a projectile whenever the player clicks
	gun = 0,
	##Fires a projectile when the player is holding down click
	auto_gun = 1,
	##Spawns a hitbox when the player clicks
	melee = 2,
}
