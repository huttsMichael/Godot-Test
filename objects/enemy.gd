extends Node3D
class_name Enemy

#signal enemy_killed

@export var player: Node3D

@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB

var EnemyScene = preload("res://objects/enemy.tscn")  # Update the path accordingly

var health := 100
var time := 0.0
var target_position: Vector3
var destroyed := false

func _ready():
	randomize()
	target_position = position

func _process(delta):
	if destroyed:
		return  # Skip processing if destroyed
	if player == null:
		return  # Wait until player is assigned
	look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)
	target_position.y += (cos(time * 5) * 1) * delta
	time += delta
	position = target_position

func damage(amount):
	if destroyed:
		return  # Prevent further damage if already destroyed
	Audio.play("sounds/enemy_hurt.ogg")
	health -= amount
	if health <= 0 and !destroyed:
		destroy()

func destroy():
	Audio.play("sounds/enemy_destroy.ogg")
	destroyed = true
	
	#enemy_killed.emit()

	# Hide the enemy and disable its functionality
	hide()
	set_process(false)
	set_physics_process(false)
	raycast.enabled = false
	$CollisionShape3D.disabled = true  # Adjust the node path if needed

	# Remove the current enemy
	queue_free()

	# Interact with LevelSpawner to expand the game world
	var spawner = get_node("/root/Main/LevelSpawner")
	spawner.expand_generation_radius()


func _on_timer_timeout():
	if destroyed:
		return  # Skip if destroyed
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("damage"):
			muzzle_a.frame = 0
			muzzle_a.play("default")
			muzzle_a.rotation_degrees.z = randf_range(-45, 45)
			muzzle_b.frame = 0
			muzzle_b.play("default")
			muzzle_b.rotation_degrees.z = randf_range(-45, 45)
			Audio.play("sounds/enemy_attack.ogg")
			collider.damage(5)
