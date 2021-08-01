extends RigidBody

export var golden = false

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
		dirt.global_transform.origin.y = 0
	
	$Detector.monitoring = true


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
