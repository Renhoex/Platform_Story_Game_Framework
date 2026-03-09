extends Node2D

func _ready() -> void:
	$Smoke.emitting = true

func _on_smoke_finished() -> void:
	queue_free()
