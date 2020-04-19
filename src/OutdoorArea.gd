extends Area2D

onready var sunlight = $Light2D
onready var cave_darknes = $Light2D2


func _on_OutdoorArea_body_entered(body):
	if body.get_name() == "Player":
		body.set_outside(true)
		sunlight.visible = false
		cave_darknes.visible = true


func _on_OutdoorArea_body_exited(body):
	if body.get_name() == "Player":
		body.set_outside(false)
		sunlight.visible = true
		cave_darknes.visible = false
