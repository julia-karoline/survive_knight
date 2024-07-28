extends Node

@export var mob_spawner: MobSpawner
@export var spawn_rate_per_minute = 30
@export var initial_spawn_rate = 60.0
@export var wave_duration = 20
@export var break_intensity = 0.5

var time = 0.0


func _process(delta):
	if GameManager.is_game_over: return
	time += delta
	
	#Dificuldade Linear linha verde
	var spawn_rate = initial_spawn_rate + spawn_rate_per_minute * (time/60.0)
	
	#sistema de ondas
	var sin_wave = sin((time * TAU)/wave_duration)
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	
	spawn_rate *= wave_factor
	
	mob_spawner.mobs_per_minute = spawn_rate
	
