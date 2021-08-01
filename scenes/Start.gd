extends Spatial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()
	
	if event.is_action_type() and event.is_pressed():
		get_tree().change_scene("res://scenes/Level1.tscn")

func _process(delta):
	$ColorRect.color.a -= delta * 0.03
