extends Node2D

onready var light = $Light


func _physics_process(delta):
	light.texture_scale = 2


func _on_Button_pressed():
	get_tree().change_scene("res://World.tscn")
