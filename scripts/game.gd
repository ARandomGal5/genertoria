extends Node

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
		else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED); 
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene();
