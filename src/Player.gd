extends KinematicBody2D

const Utils = preload("res://Utils.gd")

const ACCELERATION = 512
const MAX_SPEED = 64
const FRICTION = .25
const AIR_FRICTION = .02
const GRAVITY = 300
const JUMP_FORCE = 100
const WALL_GRAVITY = 40
const WALL_JUMP_X_FORCE = 100
const MAX_WALL_SPEED = 100

const LIGHT_DEGRADATION = .7
const LIGHT_RECHARGE = 1.7
const DARKNES_TIME = 2
const MINIMUM_LIGHT = .1


var motion = Vector2.ZERO

var can_double_jump = true
var facing_direction = -1
var light_radius = 1
var low_light_timer = 0
var is_dead = false
var played_dead_animation = false

var footsteps = [
	preload("res://audio/footsteps/footstep_gravel_run_10.WAV"),
	preload("res://audio/footsteps/footstep_gravel_run_11.WAV"),
	preload("res://audio/footsteps/footstep_gravel_run_12.WAV"),
	preload("res://audio/footsteps/footstep_gravel_run_13.WAV"),
	preload("res://audio/footsteps/footstep_gravel_run_14.WAV"),
	preload("res://audio/footsteps/footstep_gravel_run_15.WAV"),
	preload("res://audio/footsteps/footstep_gravel_run_16.WAV"),
]
const FOOTSTEP_TIME = .3
var footsteps_timer = 0
var is_in_the_air = false
onready var footstep_audio_player = $FootstepAudioPlayer

var landings = [
	preload("res://audio/landing_1.WAV"),
	preload("res://audio/landing_2.WAV"),
	preload("res://audio/landing_3.WAV"),
	preload("res://audio/landing_4.WAV"),
]
onready var landing = $Landing

var death_sounds = [
	preload("res://audio/player/death_1.wav"),
	preload("res://audio/player/death_2.wav"),
	preload("res://audio/player/death_3.wav"),
	preload("res://audio/player/death_4.wav"),
	preload("res://audio/player/death_5.wav"),
]
onready var voice_soundplayer = $VoiceAudioPlayer

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var light = $Light
onready var dark_light = $Dark

var last_bonfire = null


class PlayerInput:
	static func get_x_input():
		return Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		
	static func is_moving_horizontaly():
		return PlayerInput.get_x_input() != 0
		
	static func pressed_jump():
		return Input.is_action_just_pressed("ui_up")
		
	static func released_jump():
		return Input.is_action_just_released("ui_up")

	static func released_horizontal_movement():
		return Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left")


func _physics_process(delta):
	if not is_dead:
		if PlayerInput.is_moving_horizontaly():
			motion.x += PlayerInput.get_x_input() * ACCELERATION * delta
			motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
			facing_direction = -1 if motion.x >= 0 else 1
	
		if is_on_floor():
			_handle_floor_motion(delta)
		elif is_on_wall():
			_handle_wall_motion(delta)
		else:
			_handle_inair_motion(delta)
	
		_handle_footsteps(delta)
	else:
		motion.y += GRAVITY * delta
	
	_update_light(delta)
	_update_sprite()
	is_in_the_air = not is_on_floor()
	motion = move_and_slide(motion, Vector2.UP)


func _play_random_sound(source, sounds):
	source.stream = sounds[int(rand_range(0, len(sounds)))]
	source.play()


func _handle_footsteps(delta):
	if is_on_floor() and PlayerInput.is_moving_horizontaly():
		footsteps_timer += delta
		
		if footsteps_timer >= FOOTSTEP_TIME:
			footsteps_timer -= FOOTSTEP_TIME
			_play_random_sound(footstep_audio_player, footsteps)
	else:
		footsteps_timer = 0
	
	if is_on_floor() and PlayerInput.released_horizontal_movement():
		_play_random_sound(footstep_audio_player, footsteps)
	
	if is_in_the_air and is_on_floor():
		_play_random_sound(landing, landings)


func _handle_wall_motion(delta):
	if motion.y < 0:
		motion.y += GRAVITY * delta
	else:
		motion.y += WALL_GRAVITY * delta
	if motion.y > MAX_WALL_SPEED: motion.y = MAX_WALL_SPEED
	
	if PlayerInput.pressed_jump():
		motion.y = -JUMP_FORCE
		motion.x += facing_direction * WALL_JUMP_X_FORCE

	can_double_jump = true


func _handle_floor_motion(delta):
	motion.y += GRAVITY * delta
	
	if PlayerInput.pressed_jump():
		motion.y = -JUMP_FORCE

	if not PlayerInput.is_moving_horizontaly():
		motion.x = lerp(motion.x, 0, FRICTION)

	can_double_jump = true


func _handle_inair_motion(delta):
	motion.y += GRAVITY * delta
	
	if PlayerInput.released_jump() and motion.y < -JUMP_FORCE/2:
		motion.y = -JUMP_FORCE/2

	if PlayerInput.pressed_jump() and can_double_jump:
		motion.y = -JUMP_FORCE
		can_double_jump = false

	if not PlayerInput.is_moving_horizontaly():
		motion.x = lerp(motion.x, 0, AIR_FRICTION)


func _update_sprite():
	sprite.flip_h = facing_direction > 0

	if is_dead:
		if not played_dead_animation:
			animation_player.play("Die")
			played_dead_animation = true
	elif not is_on_floor():
		animation_player.play("Jump")
	elif PlayerInput.is_moving_horizontaly():
		animation_player.play("Run")
	else:
		animation_player.play("Stand")


func _update_light(delta):
	if (PlayerInput.is_moving_horizontaly() or motion.y < 0) and not is_dead:
		if light_radius < MINIMUM_LIGHT: light_radius = MINIMUM_LIGHT
		light_radius += LIGHT_RECHARGE * delta
	else:
		light_radius -= LIGHT_DEGRADATION * delta
		
	light_radius = clamp(light_radius, MINIMUM_LIGHT, 1)
	
	if Utils.compare_floats(light_radius, MINIMUM_LIGHT):
		low_light_timer += delta
	else:
		low_light_timer = 0

	if low_light_timer >= DARKNES_TIME:
		light_radius = 0
	
	dark_light.visible = light_radius == 0
	light.visible = light_radius > 0
	
	light.texture_scale = light_radius


func die():
	is_dead = true
	motion.x = 0
	motion.y = 0
	played_dead_animation = false
	
	_play_random_sound(voice_soundplayer, death_sounds)
	
	yield(get_tree().create_timer(1.5), "timeout")
	
	is_dead = false
	self.position = last_bonfire.position


func encounter_bonfire(bonfire):
	last_bonfire = bonfire
