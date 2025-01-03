extends Area2D


func destroy():
	queue_free()


func _on_area_entered(area):
	get_parent().get_parent().get_parent().increaseScore(1)
	destroy()
