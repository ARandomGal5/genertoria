extends State
class_name PlayerHurt
const HURT_TIME = 15;
var current_hurt_time = 0;
var hit_damage = 0;
var knock_back = Vector2(0, 0)
var damage_text = null;
func _enter():
	player.hud._create_damage_text(hit_damage, player, 0)
	$"../../Sounds/Hurt".play();
	player.health -= hit_damage;
	player.velocity.x = -knock_back.x*sign(player.direction);
	player.velocity.y = -knock_back.y;
	
func _physics_update():
	current_hurt_time += 1;
	if current_hurt_time >= HURT_TIME:
		current_hurt_time = 0;
		player.QueueHurt = false;
	player.time_since_hurt = 0;
