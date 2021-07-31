extends Spatial

onready var whole_model = $Model
onready var drop_model = $Model/Drop

var grow_speed = 0.05
var drop_grow_speed = 0.1
var growth = 0
var growing = false

var growing_drop = false

var drop_ready = true

var target_scale = 1.0

func _ready():
	target_scale = whole_model.scale.x
	baby()

func baby():
	drop_model.visible = false
	drop_ready = false
	whole_model.scale = Vector3.ONE * 0.01
	growing = true
	growth = 0

func grow_drop():
	drop_model.scale = Vector3.ONE * 0.01
	drop_model.visible = true
	growth = 0
	growing_drop = true

func take_drop():
	drop_ready = false
	$GetDrop.monitorable = false
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
		growth = min(1, growth + (grow_speed * delta))
		drop_model.scale = Vector3.ONE * growth
		if growth >= 1:
			growing = false
			growing_drop = false
			drop_ready = true
			$GetDrop.monitorable = true
	


func _on_GetDrop_on_pickup():
	take_drop()
