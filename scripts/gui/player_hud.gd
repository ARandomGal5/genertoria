extends Control
@onready var player = get_parent().get_parent();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Health/Bar.value = player.health;
	$Health/OverHeal.value = player.health;
	$Health/Number.text = str(player.health);

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
