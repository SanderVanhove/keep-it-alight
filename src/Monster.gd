extends KinematicBody2D

const MOVEMENT_SPEED = 50

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
onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite


func _ready():
	start_position = position


func _process(delta):
	light.texture_scale = .2
	
	if is_dead: return
	
	if is_active:
		var vector = (target.global_position - position).normalized() * MOVEMENT_SPEED
		move_and_slide(vector)
		animationPlayer.play("Attack")
		
		sprite.flip_h = vector[0] > 0
	else:
		animationPlayer.play("Idle")


func _on_MonsterDetection_area_entered(area):
	if area.get_name() == "VisibilityArea":
		target = area
		is_active = true
		
		heartBeatPlayer.stream = fastHearthBeat
		heartBeatPlayer.play()
	if area.get_name() == "BonfireInfluence":
		is_dead = true
		diePlayer.stream = DIE_SOUNDS[int(rand_range(0, len(DIE_SOUNDS)))]
		diePlayer.play()
		animationPlayer.play("Die")
		
		yield(get_tree().create_timer(.9), "timeout")
		hide()
		queue_free()


func _on_MonsterDetection_area_exited(area):
	if area.get_name() == "VisibilityArea":
		is_active = false
		
		heartBeatPlayer.stream = slowHearthBeat
		heartBeatPlayer.play()


func _on_MonsterDetection_body_entered(body):
	if body.get_name() == "Player":
		body.die()
		is_active = false
		
		heartBeatPlayer.stream = slowHearthBeat
		heartBeatPlayer.play()
		
		yield(get_tree().create_timer(1.5), "timeout")
		
		position = start_position
