extends Area2D


func _on_area_entered(area):
	area.queue_free()


func _on_timer_timeout():
	$CollisionPolygon2D.disabled = true
