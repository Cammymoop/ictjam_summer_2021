extends KinematicBody

export (PackedScene) var drop_projectile:PackedScene = null

onready var camera = $Camera

var gravity = -30
var max_speed = 11
var move_strength = 3
var mouse_sensitivity = 0.002  # radians/pixel

var movement_drag = 1.1

var knockback_strength = 400
var throw_force = 1500

var stunned = false
var velocity = Vector3()

var items = {"Drop": 9}


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
	return true

func _process(delta):
	if not stunned:
		if Input.is_action_just_pressed("use_item"):
			if use_item("Drop"):
				var projectile = drop_projectile.instance()
				projectile.global_transform = camera.global_transform
				projectile.add_central_force(projectile.transform.basis * Vector3.FORWARD * throw_force)
				get_parent().add_child(projectile)

func abs_limited(max_val, val):
	return max(min(val, max_val), -max_val)

func add_velocity_impulse(strength:float, direction:Vector3):
	velocity += direction.normalized() * strength


func _on_Hurtbox_area_entered(area):
	var direction = global_transform.origin - area.global_transform.origin
	
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
	
	print_debug("You now have " + str(items[item_name]) + " " + item_name)
