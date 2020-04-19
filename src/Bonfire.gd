extends Area2D


onready var light = $Light
onready var fire_crackling = $Crackling
onready var fire_flint = $Flint
onready var fire_ignite = $Ignite
onready var animation_player = $AnimationPlayer
onready var label = $Label

export(String, MULTILINE) var message


func _ready():
	animation_player.play("StillWood")
	light.visible = false
	fire_crackling.volume_db
	label.text = message


func _process(delta):
	light.texture_scale = 1


func _on_Area2D_body_entered(body):
	if not light.visible and (body.get_name() == "Player"):
		light.visible = true
		label.visible = true
		fire_crackling.play()
		fire_flint.play()
		fire_ignite.play()
		animation_player.play("Ignite")
		animation_player.queue("Burn")
		
		body.encounter_bonfire(self)
