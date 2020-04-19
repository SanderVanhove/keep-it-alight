extends Light2D


const MINIMUM_LIGHT_VIBRATION = .03

var timer = 1


func _physics_process(delta):
	timer += delta * 4
	texture_scale = texture_scale + lerp(
		-MINIMUM_LIGHT_VIBRATION * texture_scale,
		MINIMUM_LIGHT_VIBRATION * texture_scale,
		sin(timer))
