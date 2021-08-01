extends KinematicBody

export (PackedScene) var drop_projectile:PackedScene = null
export (PackedScene) var golden_drop_projectile:PackedScene = null

export var starting_drops:int = 0
export var big_start:bool = false

var water_plant_packed = preload("res://scenes/water_plant.tscn")
var golden_plant_packed = preload("res://scenes/goldenPlant.tscn")
var fountain_plant_packed = preload("res://scenes/fountainPlant.tscn")

onready var camera = $Camera

var gravity = -30
var max_speed = 11
var move_strength = 3
var mouse_sensitivity = 0.002  # radians/pixel

var jump_strength = 15

var movement_drag = 1.1

var knockback_strength = 400
var throw_force = 1500

var stunned = false
var velocity = Vector3()

var items = {"GoldenDrop": 6, "GoldenSeed": 2}

var current_item = "GoldenDrop"


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if not big_start:
		current_item = ""
		items = {}
	
	if starting_drops > 0:
		items["Drop"] = starting_drops
		current_item = "Drop"
	
	update_displayed_item()

func get_move_input():
	var input_dir = Vector3()
	# desired move in camera direction
	if Input.is_action_pressed("move_forward"):
		input_dir += -camera.global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += camera.global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -camera.global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += camera.global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.x /= movement_drag
	velocity.z /= movement_drag
	var movement_velocity = get_move_input() * move_strength
	if stunned:
		movement_velocity = Vector3.ZERO

	velocity.x = abs_limited(max_speed, velocity.x + movement_velocity.x)
	velocity.z = abs_limited(max_speed, velocity.z + movement_velocity.z)
	velocity = move_and_slide(velocity, Vector3.UP, true)

func use_item(item_name):
	if not items.has(item_name):
		return false
	
	if items[item_name] <= 0:
		return false
	
	items[item_name] -= 1
	if items[item_name] == 0:
		items.erase(item_name)
		toggle_item()
	return true

func try_item(item_name):
	if item_name == "Drop":
		if not use_item("Drop"):
			return
		var projectile = drop_projectile.instance()
		projectile.global_transform = camera.global_transform
		projectile.add_central_force(projectile.transform.basis * Vector3.FORWARD * throw_force)
		get_parent().add_child(projectile)
	elif item_name == "GoldenDrop":
		if not use_item("GoldenDrop"):
			return
		var projectile = golden_drop_projectile.instance()
		projectile.global_transform = camera.global_transform
		projectile.add_central_force(projectile.transform.basis * Vector3.FORWARD * throw_force)
		get_parent().add_child(projectile)
	elif item_name == "WaterSeed":
		var areas = $PlantLooker.get_overlapping_areas()
		if len(areas) < 1:
			return
		if not use_item("WaterSeed"):
			return
		
		var seed_transform = areas[0].global_transform
		areas[0].get_parent().queue_free()
		
		var new_plant = water_plant_packed.instance()
		get_parent().add_child(new_plant)
		new_plant.global_transform = seed_transform
		new_plant.baby()
	elif item_name == "GoldenSeed":
		var areas = $PlantLooker.get_overlapping_areas()
		if len(areas) < 1:
			return
		if not use_item("GoldenSeed"):
			return
		
		var seed_transform = areas[0].global_transform
		areas[0].get_parent().queue_free()
		
		var new_plant = golden_plant_packed.instance()
		get_parent().add_child(new_plant)
		new_plant.global_transform = seed_transform
		new_plant.baby()
	elif item_name == "FountainSeed":
		var areas = $PlantLooker.get_overlapping_areas()
		if len(areas) < 1:
			return
		if not use_item("FountainSeed"):
			return
		
		var seed_transform = areas[0].global_transform
		areas[0].get_parent().queue_free()
		
		var new_plant = fountain_plant_packed.instance()
		get_parent().add_child(new_plant)
		new_plant.global_transform = seed_transform
		new_plant.baby()

func toggle_item():
	if len(items) <= 0:
		current_item = ""
		update_displayed_item()
		return
		
	var item_names = items.keys()
	var index = item_names.find(current_item)
	if index == -1:
		index = 0
	elif len(item_names) < 2 || index == len(item_names):
		index = 0
	else:
		index += 1
	
	if index == len(item_names):
		index = 0
	
	current_item = item_names[index]
	update_displayed_item()

func update_displayed_item():
	var ItemBox = get_tree().get_nodes_in_group("InvSpot")
	if len(ItemBox) < 1:
		return
	
	var items = ItemBox[0].get_children()
	for item in items:
		if current_item == item.name:
			item.visible = true
		else:
			item.visible = false

func _process(delta):
	if not stunned:
		if Input.is_action_just_pressed("use_item"):
			try_item(current_item)
		
		if Input.is_action_just_pressed("jump"):
			var bodies = $Feet.get_overlapping_bodies()
			if len(bodies) > 0:
				add_velocity_impulse(jump_strength, Vector3.UP)
		
		if Input.is_action_just_pressed("toggle_item"):
			toggle_item()
	
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene("res://scenes/Start.tscn")

func abs_limited(max_val, val):
	return max(min(val, max_val), -max_val)

func add_velocity_impulse(strength:float, direction:Vector3):
	velocity += direction.normalized() * strength


func _on_Hurtbox_area_entered(area):
	var direction = global_transform.origin - area.global_transform.origin
	direction.y = 0
	
	add_velocity_impulse(knockback_strength, direction)
	stunned = true
	$StunTimer.start()
	
	$AnimationPlayer.play("Hurt")


func _on_StunTimer_timeout():
	stunned = false

func _on_PickupBox_area_entered(area):
	area.emit_signal("on_pickup")
	var item_name = area.item_name
	
	if items.has(item_name):
		items[item_name] += 1
	else:
		items[item_name] = 1
		if current_item == "":
			current_item = item_name
			update_displayed_item()
	
	print_debug("You now have " + str(items[item_name]) + " " + item_name)
