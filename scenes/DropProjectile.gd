extends RigidBody

func _ready():
	print_debug("particle ready")

func _on_DropProjectile_body_entered(body):
	print_debug("particle hit")
	$Particles.emitting = true
	stop_physics()
	$Projectile.visible = false
	$DeathTimer.start()
	
	$Detector.monitoring = true


func stop_physics():
	mode = RigidBody.MODE_RIGID
	collision_layer = 0
	collision_mask = 0
	contact_monitor = false
	


func _on_DeathTimer_timeout():
	print_debug("particle leaving")
	queue_free()


func _on_Detector_area_entered(area):
	area.emit_signal("put_out")
