extends Resource
class_name ProjectileStats
@export var sprite: Texture2D = null;
@export var velocity: int = 0;
@export var damage: int = 0;
@export var knock_back: Vector2 = Vector2(0, 0);
@export var hit_box: RectangleShape2D = null;
@export var heal: int = 15;
@export var kill_heal: int = 30;
