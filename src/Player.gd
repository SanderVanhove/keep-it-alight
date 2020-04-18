extends KinematicBody2D

const ACCELERATION = 512
const MAX_SPEED = 64
const FRICTION = .25
const AIR_FRICTION = .02
const GRAVITY = 250
const JUMP_FORCE = 128
const WALL_GRAVITY = 200
const WALL_JUMP_X_FORCE = 50


var motion = Vector2.ZERO

var can_double_jump = true
var facing_direction = -1

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer


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
	
	_update_sprite(motion)
	motion = move_and_slide(motion, Vector2.UP)


func _handle_wall_motion(delta):
	motion.y = WALL_GRAVITY * delta
	
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


func _update_sprite(motion):
	sprite.flip_h = facing_direction > 0

	if not is_on_floor():
		animation_player.play("Jump")
	elif PlayerInput.is_moving_horizontaly():
		animation_player.play("Run")
	else:
		animation_player.play("Stand")
