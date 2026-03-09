extends CharacterBody2D

func _physics_process(_delta: float) -> void:
	if move_and_slide():
		queue_free()

func _on_vis_box_screen_exited() -> void:
	queue_free()
