extends Area2D

func _on_area_entered(area):
	get_parent().get_parent().get_parent().decreaseHealth(1)
