extends Spatial

export var spreads:bool = true
export var extenguishable = true

var floor_elevate = -1.0

var spread_distance = 7.0
var dying = false

var player_ref = false
var from_spread = false

var max_active_distance = 90

func _ready():
	if spreads:
		$SpreadTimer.wait_time = 10.0 + (randf() * 25.0)
		$SpreadTimer.start()
	
	player_ref = get_tree().get_nodes_in_group("Player")
	if len(player_ref) < 1:
		player_ref = false
	
	if from_spread:
		check_redundant()
	else:
		$Checker.queue_free()

func check_redundant():
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var areas = $Checker.get_overlapping_areas()
	
	if len(areas) > 1:
		die()
	else:
		get_node("/root/FireMaker").spread_one()
	
	$Checker.queue_free()

func spread():
	if not get_node("/root/FireMaker").can_spread():
		return
	var new_offset = spread_distance * Vector3.FORWARD
	new_offset = new_offset.rotated(Vector3.UP, random_angle())
	
	var fire_scene = get_node("/root/FireMaker").get_fire_packed()
	
	var new_fire = fire_scene.instance()
	new_fire.from_spread = true
	get_parent().add_child(new_fire)
	new_fire.scale = scale
	new_fire.global_transform.origin = global_transform.origin + new_offset
	
	#Adjust to floor
	var floor_pos = find_floor(new_fire.global_transform.origin)
	if floor_pos < 100000:
		new_fire.global_transform.origin.y = floor_pos + floor_elevate

func find_floor(position) -> float:
	var state = PhysicsServer.space_get_direct_state(get_world().space)
	var intersection = state.intersect_ray(position + (Vector3.UP * 2), position - (Vector3.UP * 9), [], 2)
	if intersection:
		return intersection['position'].y
	else:
		return 100001.0

func random_angle():
	var angle = randf() * PI * 2.0
	return angle

func die():
	dying = true
	$DeathTimer.start()
	$FireParticles.emitting = false
	$SmokeParticles.emitting = false
	yield(get_tree(), "idle_frame")
	$Area.monitorable = false
	$Area.monitoring = false


func _on_DeathTimer_timeout():
	queue_free()


func _on_SpreadTimer_timeout():
	if dying:
		return
	if player_ref:
		var min_distance = 1000
		var my_origin = global_transform.origin
		for player in player_ref:
			min_distance = min(min_distance, my_origin.distance_to(player.global_transform.origin))
		
		if min_distance < max_active_distance:
			spread()
	else:
		spread()
	if spreads:
		$SpreadTimer.wait_time = 10.0 + (randf() * 25.0)
		$SpreadTimer.start()
	


func _on_Area_watered():
	if extenguishable:
		die()


func _on_Area_body_entered(body):
	# a plant
	body.emit_signal("fire")
