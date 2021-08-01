extends RigidBody

export var golden = false

var floor_sink = -0.1

var packed_dirt:PackedScene = preload("res://scenes/EmptySpot.tscn")

func _on_DropProjectile_body_entered(body):
	$Particles.emitting = true
	stop_physics()
	$Projectile.visible = false
	$DeathTimer.start()
	
	if golden:
		var dirt = packed_dirt.instance()
		get_parent().add_child(dirt)
		dirt.global_transform.origin = global_transform.origin
		var floor_pos = find_floor(global_transform.origin)
		if floor_pos < 100000:
			dirt.global_transform.origin.y = floor_pos - floor_sink
		else:
			print("no floor")
		
	
	$Detector.monitoring = true


func find_floor(position) -> float:
	var state = PhysicsServer.space_get_direct_state(get_world().space)
	var intersection = state.intersect_ray(position + (Vector3.UP * 1), position - (Vector3.UP * 7), [], 2)
	if intersection:
		return intersection['position'].y
	else:
		return 100001.0


func stop_physics():
	mode = RigidBody.MODE_RIGID
	collision_layer = 0
	collision_mask = 0
	


func _on_DeathTimer_timeout():
	queue_free()


func _on_Detector_area_entered(area):
	area.emit_signal("watered")


func _on_Detector_body_entered(body):
	print("water hit body")
	body.emit_signal("watered")
