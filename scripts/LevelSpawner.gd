extends Node3D

@export var player: Node3D  # Reference to the player

var PlatformScenes = [
	preload("res://objects/platform.tscn"),
	preload("res://objects/platform_large_grass.tscn"),
	# Add more platform scenes as needed
]

var WallScenes = [
	preload("res://objects/wall_high.tscn"),
	preload("res://objects/wall_low.tscn"),
	# Add more wall scenes as needed
]

var EnemyScene = preload("res://objects/enemy.tscn")  # Update path accordingly
var HealthPickupScene = preload("res://objects/health_pickup.tscn")  # Update the path

var generation_radius := 10.0  # Starting radius for generation
var generation_increment := 1.0
var max_enemies := 3
var platforms_spawned := 2
var platforms_incriment := 1

signal enemy_killed

func _ready():
	randomize()
	print("LevelSpawner _ready() called")
	if player == null:
		print("Error: 'player' is null in LevelSpawner.gd _ready()")
		# Attempt to get the player node directly
		player = get_node("/root/Main/Player")
		if player == null:
			print("Error: 'player' is still null after get_node()")
		else:
			print("Player assigned in LevelSpawner.gd _ready() after get_node(): ", player)
	else:
		print("Player assigned in LevelSpawner.gd _ready(): ", player)
	call_deferred("_initialize_level_spawner")

func _initialize_level_spawner():
	if player == null:
		print("Error: 'player' is null in LevelSpawner.gd _initialize_level_spawner()")
	else:
		print("Player assigned in LevelSpawner.gd _initialize_level_spawner(): ", player)
	generate_initial_level()

func generate_initial_level():
	for i in range(5):
		spawn_platform_or_wall()
	for i in range(3):
		spawn_new_enemy()

func spawn_platform_or_wall():
	var spawn_type = randf()
	var scene
	if spawn_type < 0.5:
		scene = PlatformScenes[randi() % PlatformScenes.size()]
	else:
		scene = WallScenes[randi() % WallScenes.size()]
	
	var instance = scene.instantiate()
	instance.position = get_random_position_within_radius()
	get_parent().call_deferred("add_child", instance)  # Add to the main scene

func get_random_position_within_radius():
	if player == null:
		print("Error: 'player' is null in get_random_position_within_radius()")
		return Vector3.ZERO  # Return a default position or handle appropriately

	var position: Vector3
	var tries := 0
	var min_distance = 10.0  # Minimum distance from the player
	while tries < 10:
		var angle = randf() * TAU
		var distance = min_distance + randf() * (generation_radius - min_distance)
		var x = player.position.x + distance * cos(angle)
		var z = player.position.z + distance * sin(angle)
		var y = player.position.y + randf_range(-2, 2)  # Adjust Y as needed
		position = Vector3(x, y, z)
		
		if is_position_free(position):
			return position
		tries += 1
	return position

func is_position_free(position: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var shape = BoxShape3D.new()
	shape.extents = Vector3(2, 2, 2)  # Adjust based on object size
	var transform = Transform3D(Basis(), position)
	var params = PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = transform
	var result = space_state.intersect_shape(params)
	return result.size() == 0

func expand_generation_radius():
	enemy_killed.emit()
	generation_radius += generation_increment
	print("Generation radius expanded to: ", generation_radius)
	
	for i in range(platforms_spawned):
		spawn_platform_or_wall()
	
	platforms_spawned += platforms_incriment
	
	spawn_new_enemy()
	max_enemies += 1
	
	spawn_health_pickup()



func spawn_new_enemy():
	var enemy_count = get_enemy_count()
	if enemy_count < max_enemies:
		for i in range(2):
			var new_enemy = EnemyScene.instantiate()
			new_enemy.position = get_random_position_within_radius()
			new_enemy.player = player
			get_parent().call_deferred("add_child", new_enemy)
			print("Spawned a new enemy. Total enemies: ", enemy_count + 1)
		
	else:
		print("Max enemies reached (", max_enemies, "). No new enemy spawned.")

func get_enemy_count():
	var count = 0
	for node in get_parent().get_children():
		if node is Enemy and not node.destroyed:
			count += 1
	print("Current enemy count: ", count)
	print("Max enemies: ", max_enemies)
	return count

	
func spawn_health_pickup():
	var pickup = HealthPickupScene.instantiate()
	pickup.position = get_random_position_within_radius()
	get_parent().call_deferred("add_child", pickup)
	
