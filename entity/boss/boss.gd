class_name Boss extends CharacterBody2D
@export var health:HealthComponent

@export var physics:bool = true
@export var default_movement:bool = true

@export var boss_script:Node
@export var hitbox:HitboxComponent

@export var sprite: CanvasGroup

@export var gravity_scale:float = 1.0

@export var defeat_timeline:TimeLineHandler

signal activated

var direction:int = -1:
	get():
		return int(remap(max(0,sign(direction)),0,1,-1,1))

var active: bool = false:
	set(value):
		if active != value:
			active = value
			# emit activated on active
			if active:
				if hitbox:
					# add hitbox back to game
					if !hitbox.is_inside_tree():
						add_child(hitbox)
				activated.emit()
			if health:
				GlobalHud.meter = 100.0

func _ready() -> void:
	if hitbox:
		hitbox.damaged.connect(_on_hitbox_damaged)
		# remove hitbox from scene until the game is activated
		hitbox.get_parent().remove_child(hitbox)
		
	if health:
		health.dead.connect(on_defeat)

func _physics_process(delta: float) -> void:
		
	if active:
		if physics:
			velocity += get_gravity()*delta*gravity_scale
		if default_movement:
			move_and_slide()
	
	if boss_script:
		boss_script.physics_process(delta)

func _process(delta: float) -> void:
	if boss_script:
		boss_script.process(delta)


func _on_hitbox_damaged() -> void:
	if sprite:
		sprite.self_modulate = Color(2.454, 2.454, 2.454, 1.0)
		await get_tree().physics_frame
		await get_tree().physics_frame
		sprite.self_modulate = Color.WHITE
	# calculate boss health meter (only update when health is changed, helps if multiple bosses are active)
	if health:
		GlobalHud.meter = (float(health.health)/float(health.max_health))*100.0

func activate() -> void:
	active = true

func on_defeat() -> void:
	active = false
	if defeat_timeline:
		defeat_timeline.activate()
	if hitbox:
		hitbox.collision_mask = 0

# call death sequence
func call_death_sequence():
	if boss_script:
		if boss_script.has_method("death_call"):
			boss_script.death_call()
