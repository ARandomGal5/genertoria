extends CharacterBody2D
class_name Enemy
@export var max_health = 100;
@export var damage = 10;
@export var knock_back = Vector2(500, 100)
@export var RecieveKnockBack: bool = true;
@export var sprites = {
	"idle" : "res://resources/sprites/npcs/enemies/dummy.png"
}
@export var hurt_sounds: Array[AudioStream]
var health = max_health;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.set_texture(load(sprites.idle))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Health.text = str(health)
	_enemy_process();
	
func _physics_process(delta: float) -> void:
	_enemy_physics_process();
	move_and_slide();

func _enemy_physics_process():
	pass;
	
func _enemy_process():
	pass;

func _take_damage(damage, attacker, heal_amount, knock_back):
	health -= damage;
	attacker.hud._create_damage_text(damage, self, 0)
	attacker.hud.dealt_damage = damage;
	
	#Check if the enemy can recieve knockback.
	if RecieveKnockBack == true:
		velocity.x = knock_back.x
		velocity.y = knock_back.y
	#If the player's current health won't be put over max ovearheal, add the health, otherwise set the player's health to max overheal.
	if attacker.health < attacker.MAX_OVERHEAL - heal_amount:
		attacker.health += heal_amount;
	else: attacker.health = attacker.MAX_OVERHEAL;
	if heal_amount > 0: attacker.hud._create_damage_text(heal_amount, attacker, 1);
	
	$HurtSound.stop();
	var random_sound = randi_range(0, hurt_sounds.size() - 1);
	$HurtSound.set_stream(hurt_sounds[random_sound]);
	$HurtSound.play();
