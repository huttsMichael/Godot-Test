extends CanvasLayer

var kills := 0
var time_remaining := 10.0  # Starting time in seconds
var timer_active := true

func _ready():
	update_timer_display()

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()
		
	if timer_active:
		time_remaining -= delta
		if time_remaining <= 0:
			time_remaining = 0
			timer_active = false
			_on_time_up()
		update_timer_display()

func update_timer_display():
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	var time_text = "%02d:%02d" % [minutes, seconds]
	$Timer.text = time_text

func _on_health_updated(health):
	$Health.text = str(health)
	
func _on_enemy_killed():
	kills += 1
	print(kills)
	$EnemiesKilled.text = str(kills)
	
	# Increase the timer when an enemy is killed
	var time_bonus := 2.0  # Time added per kill
	time_remaining += time_bonus

func _on_time_up():
	print("Time is up!")
	timer_active = false
	$GameOver.visible = true
	get_tree().paused = true
	
	# Implement game over logic here
	# For example, show a game over screen or restart the game
	
