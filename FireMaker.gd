extends Node

var FireScene = preload("res://scenes/fire.tscn")

var regulator = 0
var max_fire_per_five = 12

func _ready():
	var T = Timer.new()
	T.wait_time = 5
	T.connect("timeout", self, "_on_T")
	add_child(T)
	T.start()

func can_spread() -> bool:
	return regulator < max_fire_per_five

func spread_one():
	regulator += 1

func get_fire_packed():
	return FireScene

func _on_T():
	print_debug("reset regulator " + str(regulator))
	regulator = 0
