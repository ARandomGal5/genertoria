extends RigidBody2D
class_name Projectile
@export var stats: ProjectileStats = null;
var shooter = null;
var cursor = null;
var crit = false;


func _ready():
	#Sets the velocity of the projetile based on the velocity stat, aiming towards the player's cursor.
	linear_velocity = Vector2(stats.velocity, stats.velocity)*cursor.normalized();
	#Rotates the projectile towards the cursor.
	look_at(to_global(cursor))
	#Disable gravity.
	#mass = 0;
	#gravity_scale = 0;
	#Connect the body entered signal to the function that handles damaging enemies.
	get_child(0).connect("body_entered", _enemy_hit)
	#$Area2D.connect("body_entered", _enemy_hit);

#If the projectile collidies with something
func _enemy_hit(body):
	#Check if the collider is a valid enemy
	if body is CharacterBody2D: 
		var damage = 0;
		var heal_amount = 0;
		if crit == true: 
			damage = stats.damage*2;
			if body.health - damage > 0: heal_amount = stats.heal*2;
			else: heal_amount = stats.kill_heal*2
		else: 
			damage = stats.damage;
			if body.health - damage > 0: heal_amount = stats.heal;
			else: heal_amount = stats.kill_heal
		body._take_damage(damage, shooter, heal_amount, stats.knock_back);
	queue_free();
