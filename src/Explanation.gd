extends Area2D


const ALPHA_INCREAS = 1

export(String, MULTILINE) var text
export(AudioStream) var music
export(float) var time

onready var label = $Label
onready var audio = $AudioStreamPlayer2D

var alpha = 0


func _ready():
	label.text = text
	label.visible = false
	
	audio.stream = music


func _process(delta):
	if label.visible and alpha < 1:
		alpha += ALPHA_INCREAS * delta
		label.modulate = Color(1, 1, 1, alpha)


func _on_Explanation_body_entered(body):
	if body.get_name() == "Player" and not label.visible:
		yield(get_tree().create_timer(time), "timeout")
		audio.play()
		label.visible = true
