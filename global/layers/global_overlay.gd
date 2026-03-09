extends CanvasLayer

@onready var tween:Tween
signal fade_finished

func fade(color:Color = Color.BLACK, time:float = 0.2) -> void:
	# snap camera if faded
	if color.a <= 0.0 && get_viewport().get_camera_2d():
		get_viewport().get_camera_2d().reset_smoothing()
	
	if time > 0.0:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property($ColorRect,"color",color,time)
		await tween.finished
		fade_finished.emit()
	else:
		$ColorRect.color = color
	
	return
