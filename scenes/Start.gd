extends Spatial

var fade_speed = 0.03
var active = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()
	
	if event.is_action_type() and event.is_pressed():
		if event.is_action("Fullscreen"):
			OS.window_fullscreen = !OS.window_fullscreen
		else:
			get_tree().change_scene("res://scenes/Level1.tscn")

func _process(delta):
	if not active:
		return
	$ColorRect.color.a -= delta * fade_speed
	
	fade_speed += 0.002
	
	if $ColorRect.color.a <= 0:
		active = false
