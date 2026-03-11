extends CharacterBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

var attack_ip = false

const SPEED = 250.0
var current_dir = "down"   # default direction

func _ready():
	$AnimatedSprite2D.play("down_idle")

func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	attack()
	update_health()

	if health <= 0:
		player_alive = false
		get_tree().change_scene_to_file("res://scenes/game_over_screen.tscn")
		health = 0
		print("you died!")
		queue_free()

func player_movement(delta):
	if Input.is_action_pressed("right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = SPEED
		velocity.x = 0
	elif Input.is_action_pressed("up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -SPEED
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
		# keep last direction

	move_and_slide()

func play_anim(movement):
	var anim = $AnimatedSprite2D

	match current_dir:
		"right":
			anim.flip_h = false
			anim.play(movement == 1 ? "right_walk" : "right_idle")
		"left":
			anim.flip_h = true
			anim.play(movement == 1 ? "left_walk" : "left_idle")
		"down":
			anim.flip_h = false
			anim.play(movement == 1 ? "down_walk" : "down_idle")
		"up":
			anim.flip_h = false
			anim.play(movement == 1 ? "up_walk" : "up_idle")

func _on_player_hitbox_body_entered(body):
	if body.is_in_group("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body):
	if body.is_in_group("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown:
		health -= 10
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print("Player health:", health)

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func attack():
	if Input.is_action_just_pressed("attack"):
		print("Attack triggered, direction:", current_dir)
		attack_ip = true

		# You only have one attack animation: "all_attack"
		$AnimatedSprite2D.play("all_attack")

		$deal_attack_timer.start()

func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	attack_ip = false
	play_anim(0) # return to idle

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	healthbar.visible = true

func _on_regen_timer_timeout():
	if health < 100:
		health += 20
		if health > 100:
			health = 100
	if health <= 0:
		health = 0
