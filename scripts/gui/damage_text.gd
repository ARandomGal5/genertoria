extends Label
class_name DamageText
var target: CharacterBody2D = null;
var starting_position = global_position;
var type: types = 0;
enum types {
	damage = 0,
	heal = 1,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_settings = load("res://resources/label_settings/damage_text.tres");
	starting_position = target.global_position;
	match type:
		types.damage:
			modulate.g = 0;
			modulate.b = 0;
			text = "-" + text
		types.heal:
			modulate.r = 0;
			modulate.b = 0;
			text = "+" + text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = starting_position;
	starting_position.y -= 1;
	modulate.a -= 0.01;
