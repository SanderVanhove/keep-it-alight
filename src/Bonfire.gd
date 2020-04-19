extends Area2D


onready var light = $Light
onready var fire_crackling = $Crackling
onready var fire_flint = $Flint
onready var fire_ignite = $Ignite
onready var animation_player = $AnimationPlayer
onready var piano_player = $Piano
onready var label = $Label

export(String, MULTILINE) var message


func _ready():
	label.text = message
	animation_player.play("StillWood")


func _physics_process(delta):
	light.texture_scale = 1


func _on_Area2D_body_entered(body):
	if not light.visible and (body.get_name() == "Player"):
		light.visible = true
		label.visible = true
		
		animation_player.play("Ignite")
		animation_player.queue("Burn")
		
		fire_crackling.play()
		fire_flint.play()
		fire_ignite.play()
		
		body.encounter_bonfire(self)
		
		yield(get_tree().create_timer(.4), "timeout")
		piano_player.play()
