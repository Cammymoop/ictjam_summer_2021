extends Node

func _process(_delta):
	if Input.is_action_just_pressed("info"):
		print_debug(get_child_count())
