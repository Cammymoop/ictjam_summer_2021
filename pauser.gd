extends Node

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
