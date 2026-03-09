class_name HitboxComponent extends Area2D

@export var health:HealthComponent

@export_category("Hit Actions")
enum HIT_ACTIONS {NONE, DAMAGE, DEFLECT}
@export var hit_action:HIT_ACTIONS = HIT_ACTIONS.DAMAGE
@export var damage_audio:AudioStream = preload("res://audio/enemy/Hit.wav")
@export var reflect_audio:AudioStream = preload("res://audio/enemy/Reflect.wav")

@export_category("Action Settings")
@export var invulnerable_time:float = 0.0

signal damaged
signal deflect


func _on_body_entered(body: Node2D) -> void:
	if body is Projectile:
		match(hit_action):
			HIT_ACTIONS.DAMAGE:
				GlobalAudio.stream = damage_audio
				GlobalAudio.play()
				if invulnerable_time <= 0.0:
					health.health -= body.base_damage
				body.contact_logic()
				damaged.emit()
			HIT_ACTIONS.DEFLECT:
				GlobalAudio.stream = reflect_audio
				GlobalAudio.play()
				body.deflect()
				deflect.emit()

func _physics_process(delta: float) -> void:
	if invulnerable_time > 0.0:
		invulnerable_time -= delta


# explosion damage detection
func _on_area_entered(area: Area2D) -> void:
	if area is Explosion:
		GlobalAudio.stream = damage_audio
		GlobalAudio.play()
		if invulnerable_time <= 0.0:
			health.health -= area.base_damage
		damaged.emit()
