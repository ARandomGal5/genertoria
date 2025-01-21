extends Enemy
class_name EnemyDummy

func _enemy_process():
	if health < 100: health = 100;
