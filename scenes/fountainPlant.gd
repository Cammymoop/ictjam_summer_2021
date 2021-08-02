extends Spatial

onready var whole_model = $Model
onready var cube_models = $Model/Empty

export var start_baby:bool = true

var dirt = preload("res://scenes/EmptySpot.tscn")

var is_baby = false
var is_adult = true
var active = false
export var grow_speed = 0.01
var growth = 0
var growing = false

var water_amount = 0.0
export var starting_water = 0.5
export var water_drain = 0.002
var refill_amount = 0.34

var seed_available = false
var seed_started = false

var target_scale = 1.0
var cubes_target_scale = 1.0
var particle_groups = 5

var warding_mask = 0

func _ready():
	target_scale = whole_model.scale.x
	cubes_target_scale = cube_models.get_node("Cube").scale.x
	warding_mask = $FireWarding.collision_layer
	
	if start_baby:
		baby()
	else:
		water_amount = 1.0
		activate()

func baby():
	is_baby = true
	is_adult = false
	deactivate()
	whole_model.scale = Vector3.ONE * 0.001
	growing = false
	growth = 0

func watered():
	growing = true
	is_baby = false

func _process(delta):
	if not growing and not active:
		return
	
	if growing:
		growth = min(1, growth + (grow_speed * delta))
		whole_model.scale = target_scale * Vector3.ONE * growth
		if growth >= 1:
			growing = false
			is_adult = true
			add_water(starting_water)
	
	if active:
		water_amount -= delta * water_drain
		if water_amount < 0:
			deactivate()
		else:
			var new_scale = cubes_target_scale * Vector3.ONE * water_amount
			for cube in cube_models.get_children():
				cube.scale = new_scale
			
			var max_index = floor(water_amount * particle_groups)
			for part_i in range(particle_groups):
				$ParticleEmitters.get_child(part_i).emitting = true if part_i <= max_index else false
		
		

func deactivate():
	water_amount = 0.0
	active = false
	$FireWarding.collision_layer = 0
	
	for cube in cube_models.get_children():
		cube.scale = Vector3.ZERO
	
	for particle in $ParticleEmitters.get_children():
		particle.emitting = false

func activate():
	active = true
	$FireWarding.collision_layer = warding_mask
	if not seed_started:
		seed_started = true
		$SeedTimer.start()

func add_water(amount):
	if not active:
		activate()
	water_amount += amount
	if water_amount > 1:
		water_amount = 1.0

func _on_StaticBody_watered():
	if is_baby:
		watered()
	elif is_adult:
		add_water(refill_amount)

func _on_StaticBody_fire():
	# Oh no, burning up for you
	var new_dirt = dirt.instance()
	get_parent().add_child(new_dirt)
	new_dirt.global_transform = global_transform
	
	queue_free()



func _on_GetDrop_on_pickup():
	$Seed.visible = false
	seed_available = false
	$GetDrop.collision_layer = 0
	$GetDrop.collision_mask = 0
	$GetDrop.monitorable = false
	# Only 1 seed per fountain


func _on_SeedTimer_timeout():
	$Seed.visible = true
	seed_available = true
	yield(get_tree(), "idle_frame")
	$GetDrop.monitorable = true
