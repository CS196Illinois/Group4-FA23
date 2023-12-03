extends Sprite2D
func _on_Area2D_area_shape_entered(area_is, area, area_shape, local_shape):
	if area.get_parent().name=="head":
		find_parent("main").get_node("snake").addtail()
		queue_free()
	pass
