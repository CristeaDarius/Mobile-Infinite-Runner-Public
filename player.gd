extends CharacterBody2D

const SPEED = 75

var btnMov = 0

func _physics_process(delta):
	var tilt = 0
	if get_parent().save_data.moveTilt:
		tilt = Input.get_accelerometer().x
	
	if OS.get_name() != "Android" and OS.get_name() != "iOS":
		tilt = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		tilt *= 2
	
	var mov = tilt
	mov += btnMov
	
	if abs(mov) > 1:
		velocity.x = SPEED * sign(mov)
	else:
		velocity.x = 0
	
	move_and_slide()

func _on_button_right_button_down(): btnMov = 1.1

func _on_button_right_button_up(): btnMov = 0

func _on_button_left_button_down(): btnMov = -1.1

func _on_button_left_button_up():btnMov = 0
