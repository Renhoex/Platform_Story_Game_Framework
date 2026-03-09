@tool
class_name Projectile extends CharacterBody2D

enum MOVEMENT {INTANGIBLE, TANGIBLE, WAVY}
enum ANIMATIONS {DEFAULT, WAVE, ROCKET}
@export var movement_type:MOVEMENT = MOVEMENT.INTANGIBLE
@export_category("Animations")
@export var animation:ANIMATIONS = ANIMATIONS.DEFAULT:
	set(value):
		animation = value
		if $Sprite.sprite_frames.has_animation(ANIMATIONS.keys()[value].to_lower()):
			$Sprite.play(ANIMATIONS.keys()[value].to_lower())
@export var hit_animation = ""

@export_category("Spawn related")
@export var particle_animation:String = "buster" # called in weapon manager for what particle animation to play
@export var fire_speed:float = 320.0 # how fast to move on spawn

@export_category("Logic")
@export var live_on_last_shot:bool = false
@export var base_damage:float = 1.0

var weapon_manager = null
@export var life_time:float = 0.0 # 0 wont' ever count down, higher numbers count down and delete
var ticker:float = 0.0 # ticker is a counter that constantly counts up and down, 

@export_category("Actions")
@export var collide_scene:PackedScene # what to spawn after we collide with something (enemy or wall)


func _ready() -> void:
	animation = animation

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
		return
	ticker += delta
	match(movement_type):
		MOVEMENT.INTANGIBLE:
			translate(velocity * delta)
		MOVEMENT.TANGIBLE:
			if move_and_slide():
				GlobalAudio.stream = preload("res://audio/weapons/Impact.wav")
				GlobalAudio.play()
				if get_last_slide_collision().get_collider() is Block:
					get_last_slide_collision().get_collider().destroy()
				contact_logic(true)
		MOVEMENT.WAVY:
			# same as intangible but add oscillating movement based on the ticker
			translate(velocity * delta)
			# sway
			translate(velocity.normalized().rotated(deg_to_rad(90.0)) * (cos((ticker) * 32.0) * 60.0 * 4.0) * delta )
	# countdown
	if life_time >= ticker:
		queue_free()

func _on_screen_notifier_screen_exited() -> void:
	if Engine.is_editor_hint(): return
	queue_free()

func contact_logic(object_alive:bool = true) -> void:
	if !live_on_last_shot || object_alive:
		if hit_animation && $Sprite.sprite_frames.has_animation(hit_animation):
			set_process(false)
			set_physics_process(false)
			collision_layer = 0
			collision_mask = 0
			$Sprite.play(hit_animation)
			await $Sprite.animation_finished
		if collide_scene:
			var col_scene = collide_scene.instantiate()
			col_scene.global_position = global_position
			add_sibling(col_scene)
		queue_free()

# disable and go away
func deflect() -> void:
	collision_layer = 0
	collision_mask = 0
	velocity = -velocity
	if velocity.y == 0.0:
		velocity.y = -abs(velocity.x)

func _exit_tree() -> void:
	if weapon_manager:
		weapon_manager.projectile_table.erase(self)
