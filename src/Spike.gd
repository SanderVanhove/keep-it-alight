extends Area2D


onready var sprite = $Sprite


func _on_Spike_body_entered(body):
	if (body.get_name() == "Player"):
		body.die()
		sprite.frame = 1
