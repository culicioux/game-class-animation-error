extends CharacterBody2D


var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 1000
var player_alive = true

var attack_ip = false

const SPEED = 250.0
var current_dir = "none"

func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	attack()

	if health <= 0:
		player_alive = false #"you died!" screen here
		get_tree().change_scene_to_file("res://scenes/game_over_screen.tscn")
		health = 0
		print("you died!")
		self.queue_free()
		

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

	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play ("side_walk")
		elif movement == 0:
				anim.play("side_walk")

	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play ("side_walk")
		elif movement == 0:
				anim.play("side_walk")

	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play ("front_walk")
		elif movement == 0:
				anim.play("front_walk") 

	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play ("back_walk")
		elif movement == 0:
				anim.play("back_walk") 


func player():
	pass

func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy1"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy1"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health = health - 100
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print(health)
		

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func attack():
	var dir = current_dir
	if Input.get_action_strength("attack"):
		global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("front_attack")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("front_attack")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("front_attack")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("front_attack")
			$deal_attack_timer.start()

func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()

	global.player_current_attack = false
	attack_ip = false

func update_health():
	var healthbar = $healthbar
	healthbar.value = health

	if health >= 1000:
		healthbar.visible = false
	else: 
		healthbar.visible = true

func _on_regen_timer_timeout():
	if health < 1000:
		health = health + 200
		if health > 1000:
			health = 1000
	if health <= 0:
		health = 0
