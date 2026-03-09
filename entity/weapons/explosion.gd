extends Area2D
class_name Explosion

@export var base_damage: int = 5

func _ready() -> void:
	$Smoke.emitting = true

func _on_smoke_finished() -> void:
	queue_free()

# disable on the sprite animation finishing
func _on_explosion_animation_finished() -> void:
	collision_mask = 0

func _physics_process(_delta: float) -> void:
	for i in get_overlapping_bodies():
		if i is Block:
			i.destroy()
