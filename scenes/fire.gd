extends Spatial

export var spreads:bool = true

var spread_distance = 7.0
var dying = false

var player_ref = false

var max_active_distance = 90

func _ready():
	if spreads:
		$SpreadTimer.wait_time = 10.0 + (randf() * 25.0)
		$SpreadTimer.start()
	
	player_ref = get_tree().get_nodes_in_group("Player")
	if len(player_ref) < 1:
		player_ref = false

func check_redundant():
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var areas = $Area.get_overlapping_areas()
	
	if len(areas) > 2:
		die()

func spread():
	var new_offset = spread_distance * Vector3.FORWARD
	new_offset = new_offset.rotated(Vector3.UP, random_angle())
	
	var fire_scene = get_node("/root/FireMaker").get_fire_packed()
	
	var new_fire = fire_scene.instance()
	get_parent().add_child(new_fire)
	new_fire.global_transform.origin = global_transform.origin + new_offset
	
	new_fire.check_redundant()

func random_angle():
	var angle = randf() * PI * 2.0
	return angle

func _on_Area_put_out():
	die()

func die():
	dying = true
	$DeathTimer.start()
	$FireParticles.emitting = false
	$SmokeParticles.emitting = false
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
	
