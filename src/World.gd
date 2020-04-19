extends Node2D


onready var player = $Player
onready var player_start = $PlayerStart


# Called when the node enters the scene tree for the first time.
func _ready():
	if not player:
		var projectile = load("res://Player.tscn")
		player = projectile.instance()
		player.position = player_start.position
		add_child_below_node(self, player)
