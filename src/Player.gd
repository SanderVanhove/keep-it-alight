extends KinematicBody2D

const Utils = preload("res://Utils.gd")

const ACCELERATION = 512
const MAX_SPEED = 64
const FRICTION = .25
const AIR_FRICTION = .02
const GRAVITY = 300
const JUMP_FORCE = 100
const WALL_GRAVITY = 40
const WALL_JUMP_X_FORCE = 50

const LIGHT_DEGRADATION = .7
const LIGHT_RECHARGE = 2
const MINIMUM_LIGHT = .07
const DARKNES_TIME = 2


var motion = Vector2.ZERO

var can_double_jump = true
var facing_direction = -1
var light_radius = 1
var low_light_timer = 0

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var light = $Light
onready var dark_light = $Dark


class PlayerInput:
	static func get_x_input():
		return Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		
	static func is_moving_horizontaly():
		return PlayerInput.get_x_input() != 0
		
	static func pressed_jump():
		return Input.is_action_just_pressed("ui_up")
		
	static func released_jump():
		return Input.is_action_just_released("ui_up")


func _physics_process(delta):
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
	
	_update_light(delta)
	_update_sprite()
	motion = move_and_slide(motion, Vector2.UP)


func _handle_wall_motion(delta):
	if motion.y < 0:
		motion.y += GRAVITY * delta
	else:
		motion.y += WALL_GRAVITY * delta
	
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

	if not is_on_floor():
		animation_player.play("Jump")
	elif PlayerInput.is_moving_horizontaly():
		animation_player.play("Run")
	else:
		animation_player.play("Stand")


func _update_light(delta):
	if PlayerInput.is_moving_horizontaly() or motion.y < 0:
		if light_radius == 0: light_radius = MINIMUM_LIGHT
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
