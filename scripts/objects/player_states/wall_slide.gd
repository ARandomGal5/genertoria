extends State
class_name PlayerWallSlide

func _enter():
	$"../../Sounds/WallSlide".play();
	
func _physics_update():
	player.velocity.y = 100;
func _update():
	if $"../../Sounds/WallSlide".playing == false: $"../../Sounds/WallSlide".play();
func _exit():
	$"../../Sounds/WallSlide".stop();
