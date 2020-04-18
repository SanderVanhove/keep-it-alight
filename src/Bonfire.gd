extends Area2D


onready var light = $Light2D
onready var animation_player = $AnimationPlayer


func _ready():
	animation_player.play("StillWood")
	light.visible = false


func _on_Area2D_body_entered(body):
	if (body.get_name() == "Player"):
		light.visible = true
		animation_player.play("Ignite")
		animation_player.queue("Burn")
		
