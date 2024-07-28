class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed = 3
@export_category("Sword")
@export var sword_damage = 2
@export_category("Ritual")
@export var ritual_damage_points = 2
@export var ritual_damage_interval = 15
@export var ritual_protection_interval = 30
@export var ritual_damage_scene: PackedScene
@export var ritual_protection_scene: PackedScene
@export_category("Life")
@export var health = 100
@export var max_health = 100
@export var death_prefab: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown = 0.0
var ritual_damage_cooldown = 0.0
var ritual_protection_cooldown = 0.0

signal meat_collected(value:int)

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value:int):GameManager.meat_counter += 1)

func _process(delta):
	GameManager.player_position = position
	read_input()
	update_attack_cooldown(delta)
	
	#attack
	if Input.is_action_just_pressed("attack"):
		attack()
	
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
		
	#processar dano
	update_hitbox_detection(delta)
	
	update_ritual_protection(delta)
	#update Ritual
	update_ritual_damage(delta)
	
	
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health
	
func _physics_process(delta):
	#obter o input vector
	#modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()

func update_attack_cooldown(delta):
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func update_ritual_damage(delta):
	#atualizar temporizador
	ritual_damage_cooldown -= delta
	if ritual_damage_cooldown > 0: return
	ritual_damage_cooldown = ritual_damage_interval
	#cirar ritual
	var ritual_damage = ritual_damage_scene.instantiate()
	ritual_damage.damage_amount = ritual_damage_points
	add_child(ritual_damage)

func update_ritual_protection(delta):
#	atualizar temporizador
	ritual_protection_cooldown -= delta
	if GameManager.monsters_defeated_counter < 30: return
	if ritual_protection_cooldown > 0: return
	ritual_protection_cooldown = ritual_protection_interval
	#cirar ritual
	var ritual_protection = ritual_protection_scene.instantiate()
	hitbox_cooldown = 5.0
	add_child(ritual_protection)

func read_input():
	input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	
	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
	
	#atualizar o is running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func play_run_idle_animation():
	
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite():
		#girar sprite
	if input_vector.x >0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true
	#marcar flip h
	
func attack():
	if is_attacking:
		return
	if input_vector.y < 0:
		animation_player.play("attack_up1")
	elif input_vector.y > 0:
		animation_player.play("attack_down1")
	elif input_vector.x >= 0:
		animation_player.play("attack_side1")
	else:
		animation_player.play("attack_side2")
	attack_cooldown = 0.6
	is_attacking = true
		

func deal_damage_to_enemies():
	#acessar todos os inimigos
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if input_vector.y < 0:
				attack_direction = Vector2.UP
			elif input_vector.y > 0:
				attack_direction = Vector2.DOWN
			elif sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.damage(sword_damage)

func update_hitbox_detection(delta):
	#temporizador 
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	#frequencia
	hitbox_cooldown = 0.5
	#gitbox area
	if update_ritual_protection(delta):
		hitbox_cooldown = 5.0

	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)
			
func damage(amount):
	if health <= 0: return
	
	health -= amount
	print("Player recebeu dano de ", amount,".A vida total é de ", health)
	
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	if health <= 0:
		die()
			

func die():
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	queue_free()	

func heal(amount):
	health += amount
	if health > max_health:
		health = max_health
	print("Player recebeu cura de ", amount,". A vida total é de ", health,"/",max_health)
	return health
