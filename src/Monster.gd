extends KinematicBody2D

const MOVEMENT_SPEED = 50
const SLOW_MOVEMENT_SPEED = 30

var is_active = false
var target = null
var start_position = null
var is_dead = false


const DIE_SOUNDS = [
	preload("res://audio/monster/die_1.wav"),
	preload("res://audio/monster/die_2.wav"),
	preload("res://audio/monster/die_3.wav"),
	preload("res://audio/monster/die_4.wav"),
	preload("res://audio/monster/die_5.wav"),
]

var slowHearthBeat = preload("res://audio/player/heartbeat_slow.wav")
var fastHearthBeat = preload("res://audio/player/heartbeat_fast.wav")

onready var light = $Light
onready var heartBeatPlayer = $HeartBeatPlayer
onready var diePlayer = $DiePlayer
onready var chase_player = $ChasePlayer
onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite

onready var patrol_start = $Patrol_Start
onready var patrol_end = $Patrol_End
onready var original_start_patrol = patrol_start.global_position
onready var original_end_patrol = patrol_end.global_position


func _ready():
	start_position = position
	target = patrol_end


func _process(delta):
	light.texture_scale = .2
	
	if is_dead: return
	var current_pos = position
	var vector = Vector2(0, 0)
	
	if is_active:
		vector = (target.global_position - position).normalized() * MOVEMENT_SPEED
		move_and_slide(vector)
		animationPlayer.play("Attack")
		
		
	else:
		animationPlayer.play("Idle")
		
		if target:
			var distance = target.global_position - position
			vector = distance.normalized() * SLOW_MOVEMENT_SPEED
			move_and_slide(vector)
			
			if distance.length() < 10:
				target = patrol_start if target == patrol_end else patrol_end
	
	sprite.flip_h = vector[0] > 0
	patrol_start.position -= position - current_pos
	patrol_end.position -= position - current_pos


func _on_MonsterDetection_area_entered(area):
	if area.get_name() == "VisibilityArea":
		target = area
		is_active = true
		
		heartBeatPlayer.stream = fastHearthBeat
		heartBeatPlayer.play()
		chase_player.play()
	if area.get_name() == "BonfireInfluence":
		is_dead = true
		chase_player.stop()
		diePlayer.stream = DIE_SOUNDS[int(rand_range(0, len(DIE_SOUNDS)))]
		diePlayer.play()
		animationPlayer.play("Die")
		
		yield(get_tree().create_timer(.9), "timeout")
		hide()
		queue_free()


func _on_MonsterDetection_area_exited(area):
	if area.get_name() == "VisibilityArea":
		is_active = false
		target = null
		chase_player.stop()
		heartBeatPlayer.stream = slowHearthBeat
		heartBeatPlayer.play()
		
		yield(get_tree().create_timer(1), "timeout")
		target = patrol_start
		patrol_start.global_position = original_start_patrol
		patrol_end.global_position = original_end_patrol


func _on_MonsterDetection_body_entered(body):
	if body.get_name() == "Player":
		body.die()
		is_active = false
		
		heartBeatPlayer.stream = slowHearthBeat
		heartBeatPlayer.play()
		
		yield(get_tree().create_timer(1.5), "timeout")
		
		position = start_position
