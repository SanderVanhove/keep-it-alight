extends Node2D


var is_done = false
var birds = preload("res://audio/birds.WAV")


func _ready():
	$AnimationPlayer.play("Girl")


func _physics_process(delta):
	if is_done:
		$Light2D.energy += 1


func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		body.hide()
		body.stop()
		
		$girl.visible = false
		$endSprite.visible = true
		$AnimationPlayer.play("End")
		$Camera2D.current = true
		
		yield(get_tree().create_timer(3.5), "timeout")
		is_done = true
		$Label.visible = true
		
		yield(get_tree().create_timer(3), "timeout")
		get_tree().change_scene("res://Menu.tscn")
