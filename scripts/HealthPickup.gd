extends Node3D

@export var health_amount: int = 25  # Amount of health restored

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if body.health < body.max_health:
			body.damage(-health_amount)
			Audio.play("sounds/health_pickup.ogg")
			queue_free()  # Remove the pickup from the scene
