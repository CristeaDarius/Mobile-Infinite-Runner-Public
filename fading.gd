extends Button

var alpha = 255
var fading_out = true

func _process(delta):
	if fading_out:
		alpha -= 100 * delta 
		if alpha <= 100:
			alpha = 100
			fading_out = false
	else:
		alpha += 150 * delta
		if alpha >= 255:
			alpha = 255
			fading_out = true
	modulate = Color(1, 1, 1, alpha / 255.0)
