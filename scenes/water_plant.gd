extends Spatial

onready var whole_model = $Model
onready var drop_model = $Model/Drop

export var start_baby:bool = true

var dirt = preload("res://scenes/EmptySpot.tscn")

var is_baby = false
export var grow_speed = 0.01
export var drop_grow_speed = 0.18
var growth = 0
var growing = false

var growing_drop = false

var drop_ready = true
var seed_available = false
var first_seed = false

var target_scale = 1.0

func _ready():
	target_scale = whole_model.scale.x
	if start_baby:
		baby()
	else:
		$GetDrop.monitorable = true
		drop_ready = true

func baby():
	is_baby = true
	drop_model.visible = false
	drop_ready = false
	whole_model.scale = Vector3.ONE * 0.001
	growing = false
	growth = 0

func watered():
	growing = true
	is_baby = false

func grow_drop():
	drop_model.scale = Vector3.ZERO
	drop_model.visible = true
	growth = -0.6
	growing_drop = true

func take_drop():
	drop_ready = false
	$GetDrop.monitorable = false
	if not first_seed:
		first_seed = true
		$SeedTimer.start()
	grow_drop()

func _process(delta):
	if not growing and not growing_drop:
		return
	
	if growing:
		growth = min(1, growth + (grow_speed * delta))
		whole_model.scale = target_scale * Vector3.ONE * growth
		if growth >= 1:
			growing = false
			grow_drop()
	elif growing_drop:
		growth = min(1, growth + (drop_grow_speed * delta))
		if growth > 0:
			drop_model.scale = Vector3.ONE * growth
		if growth >= 1:
			growing = false
			growing_drop = false
			drop_ready = true
			$GetDrop.monitorable = true
	


func _on_GetDrop_on_pickup():
	take_drop()


func _on_StaticBody_watered():
	if is_baby:
		watered()

func _on_StaticBody_fire():
	# Oh no, burning up for you
	var new_dirt = dirt.instance()
	get_parent().add_child(new_dirt)
	new_dirt.global_transform = global_transform
	
	queue_free()


func _on_GetDrop2_on_pickup():
	$Seed.visible = false
	seed_available = false
	$GetDrop2.monitorable = false
	$SeedTimer.wait_time *= 2
	$SeedTimer.start()


func _on_SeedTimer_timeout():
	$Seed.visible = true
	seed_available = true
	yield(get_tree(), "idle_frame")
	$GetDrop2.monitorable = true
