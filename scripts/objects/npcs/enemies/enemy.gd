extends CharacterBody2D
class_name Enemy
@export var max_health = 100;
@export var damage = 10;
@export var knock_back = Vector2(500, 100)
@export var sprites = {
	"idle" : "res://resources/sprites/npcs/enemies/dummy.png"
}
var health = max_health;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.set_texture(load(sprites.idle))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Health.text = str(health)
	if health < 100: health = 100;
