extends RigidBody2D
class_name Projectile
var stats: ProjectileStats = null;
var shooter = null;
var cursor = null;
var crit = false;

func _ready():
	#Checks if this projectile has a sprite
	if stats.sprite != null:
		#Creates a new sprite 2D node
		var sprite = Sprite2D.new();
		#Applies the sprite as it's texture
		sprite.texture = stats.sprite;
		#Upscales the pixel art to 4x
		sprite.scale = Vector2(2, 2)
		#Adds the sprite as a child of this projectile.
		add_child(sprite);
		
	#Sets the velocity of the projetile based on the velocity stat, aiming towards the player's cursor.
	linear_velocity = Vector2(stats.velocity, stats.velocity)*cursor.normalized();
	#Rotates the projectile towards the cursor.
	look_at(to_global(cursor))
	#Disable gravity.
	mass = 0;
	gravity_scale = 0;
	#Connect the body entered signal to the function that handles damaging enemies.
	get_child(0).connect("body_entered", _enemy_hit)

#If the projectile collidies with something
func _enemy_hit(body):
	#Check if the collider is a valid enemy
	if body is CharacterBody2D: 
		#Roll for a crit, choose a random number between 0 and 100, if the number is equal to or less than the weapon's crit chance, deal a crit.
		if crit == true:
			#If a crit is successful, deal 3x damage
			body.health -= stats.damage*3;
			shooter.hud._create_damage_text(stats.damage*3, body, 0)
		else:
			body.health -= stats.damage;
			shooter.hud._create_damage_text(stats.damage, body, 0)
		
		#Initilize a variable to decide how much the player gets hit for damaging an enemy.
		var heal_amount = 0;
		#If the enemy is still alive, use the base heal amount, otherwise use the kill heal amount.
		if body.health >= 0: 
			if crit == true: 
				heal_amount = stats.heal*3
			else:
				heal_amount = stats.heal
		else: 
			if crit == true: 
				heal_amount = stats.kill_heal*3
			else:
				heal_amount = stats.kill_heal
		
		#If the player's current health won't be put over max ovearheal, add the health, otherwise set the player's health to max overheal.
		if shooter.health < shooter.MAX_OVERHEAL - heal_amount:
			shooter.health += heal_amount;
		else: shooter.health = shooter.MAX_OVERHEAL;
		shooter.hud._create_damage_text(heal_amount, shooter, 1);
	queue_free();
