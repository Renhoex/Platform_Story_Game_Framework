class_name Player extends CharacterBody2D

static var direction:int = 1:
	get():
		return int(remap(max(0,sign(direction)),0,1,-1,1))

enum STATES {NORMAL, INSPECT, IDLE, TRIP, DEBUG}

var state:STATES = STATES.NORMAL:
	set(value):
		if value < 0:
			state = value
		elif value != state || state_node == null:
			%StateMachine.get_child(state).exit()
			state = value
			state_node = %StateMachine.get_child(state)
			%StateMachine.get_child(state).enter()

var state_node:PlayerState = null

var animation:String = "idle":
	set(value):
		if animation != value:
			animation = value
			if animator.has_animation(value+animation_affix):
				animator.play(value+animation_affix)
			else:
				animator.play(value)
var animation_affix:String = "":
	set(value):
		if animation_affix != value:
			animation_affix = value
			var anim_offset:float = animator.current_animation_position
			
			if animator.has_animation(animation+animation_affix) && animator.current_animation != animation+animation_affix:
				animator.play(animation+animation_affix)
				animator.advance(anim_offset)

@onready var animator: AnimationPlayer = $Animator

@onready var sounds: AudioStreamPlayer = $Sounds
@onready var weapon_sounds: AudioStreamPlayer = $WeaponSounds

var projectile_table:Array[Projectile] = []

# physics
const WALK:float = 105.0
const MOMENTUM:float = 320.0
const MAX_FALL:float = 240.0

@onready var water_hitbox: Area2D = $WaterHitbox
var water:bool = false

@onready var hazard_hitbox: Area2D = $HazardHitbox


@onready var input_manager: InputManager = $InputManager
#@onready var weapon_manager: Node = $WeaponManager
@onready var fire_point: Marker2D = $Sprite/FirePoint
@onready var sprite: Node2D = $Sprite
@onready var sprite_material:ShaderMaterial = $Sprite/Sprite.material
@onready var health: HealthComponent = $Health

const BIG_PUFF = preload("uid://bahac67suqrjr")


var fire_time:float = 0.0
var invincibility_time:float = 0.0
var locked:bool = false:
	set(value):
		locked = value
		input_manager.locked = locked

var boss:Boss = null

@export var ready_on_spawn = true

# these are used for health memory
static var current_health:int = 0
static var max_health:int = 0

static var spawn_point:Vector2 = Vector2.ZERO
static var go_to_spawn:bool = false

func _ready() -> void:
	# set overlay node to show our stats
	GlobalHud.player = self
	#initialize state
	state = state
	GlobalOverlay.fade(Color.BLACK,0.0)
	GlobalOverlay.fade(Color(0,0,0,0))
	#connect with floor
	move_and_slide()
	# set pause action
	input_manager.start_pressed.connect(pause_handling)
	GlobalWeapons.weapon_changed.connect(update_weapon_display)
	update_weapon_display()
	
	input_manager.shoot_pressed.connect(shoot_pressed)
	# check if max health memory is at 0, if it is then load the default settings
	# you can set this to 0 if you're wanting to reset the players max health
	if max_health == 0:
		max_health = health.max_health
		current_health = health.health
	else: # else set the health and max health
		health.max_health = max_health
		health.health = current_health
	
	if go_to_spawn:
		# set respawn to false to allow room loading to work properly
		go_to_spawn = false
		global_position = spawn_point
	
	# set up weapon switching
	input_manager.l_pressed.connect(GlobalWeapons.quick_switch.bind(-1))
	input_manager.r_pressed.connect(GlobalWeapons.quick_switch.bind(1))
	
	# select first available weapon if one's available
	if GlobalWeapons.weapon_index == GlobalWeapons.WEAPONS.NONE:
		for i:Weapon in GlobalWeapons.weapon_objects:
			if i.collected:
				GlobalWeapons.weapon_index = i.get_index() as GlobalWeapons.WEAPONS
				break
	%Particle.hide()

func _process(delta: float) -> void:
	if locked: return
	%StateMachine.get_child(state).process(delta)


func _physics_process(delta: float) -> void:
	if locked: return
	%StateMachine.get_child(state).physics(delta)
	
	
	# flashing sprites (only turn the sprite invisible and not the group)
	if invincibility_time > 0.0:
		invincibility_time -= delta
		
		$Sprite/Sprite.visible = !$Sprite/Sprite.visible
		
		if invincibility_time <= 0.0:
			$Sprite/Sprite.visible = true
	
	# check for spikes and hazards
	if get_last_slide_collision() && invincibility_time <= 0:
		# check that collission layer has spike layer checked
		if PhysicsServer2D.body_get_collision_layer(get_last_slide_collision().get_collider_rid()) & (1 << 7):
			die()
	
	# check for hazards
	if hazard_hitbox.has_overlapping_bodies():
		do_damage(10)
	
	# check if there's any overlapping inspecting points
	if %InteractBox.has_overlapping_areas():
		var get_overlap_area:Area2D = %InteractBox.get_overlapping_areas()[0]
		if get_overlap_area is InteractTrigger:
			if get_overlap_area.activate_on_touch:
				interact_trigger(get_overlap_area)
	
	
	# Firing logic (mostly auto fire)
	if GlobalWeapons.weapon:
		if GlobalWeapons.weapon.auto_fire_rate > 0.0:
			if input_manager.button_shoot:
				fire_time += delta
			else:
				fire_time = 0.0
			# if beyond the auto fire timer, press the fire button
			if fire_time >= GlobalWeapons.weapon.auto_fire_rate:
				shoot_pressed()
				fire_time = 0.0
	else:
		fire_time = 0.0
	
	# water logic
	var was_in_water = water
	
	water = (water_hitbox.has_overlapping_areas() || water_hitbox.has_overlapping_bodies())
	# entering water
	if water != was_in_water:
		$Splash.global_position = global_position
		$Splash.reset_physics_interpolation()
		$Splash.restart()
		$Splash.emitting = true
		# vertical calculations
		# slow speed if entering
		if water:
			velocity *= 0.5
		# add speed if exiting
		else:
			velocity.y *= 1.5
		

func default_sprite_handling():
	sprite.scale.x = sign(direction)


func standard_physics(delta:float) -> void:
	var grav_multiplier:float = 1.0
	# decrease gravity if in water
	if water:
		grav_multiplier = 0.45
	
	if velocity.dot(get_gravity().normalized()) < MAX_FALL:
		# fast falling if the jump button isn't held
		if !input_manager.button_jump:
			if velocity.y < 0:
				velocity += get_gravity()*delta * grav_multiplier
		# apply gravity
		velocity += get_gravity() * delta * grav_multiplier
	# record last landing state
	var was_on_floor:bool = is_on_floor()
	move_and_slide()
	# if on land now but not before move and slide then run landing routine
	if is_on_floor() && ! was_on_floor:
		sounds.stream = preload("res://audio/player/Land.wav")
		sounds.play()
	if is_on_ceiling():
		sounds.stream = preload("res://audio/player/Bump.wav")
		sounds.play()
		%PartBump.emitting = true
	

func jump_action() -> void:
	if is_on_floor():
		var jump_multiply:float = 1.0
		if water:
			jump_multiply = 0.75
		velocity.y = -190.0 * jump_multiply
		sounds.stream = preload("res://audio/player/Jump.wav")
		sounds.play()

func do_damage(damage:int = 1,hit_direction:int = -1) -> void:
	if state == STATES.DEBUG: return
	if invincibility_time <= 0.0:
		velocity = Vector2(float(hit_direction)*60.0,-120.0)
		health.health -= abs(damage)
		if health.health <= 0:
			die()
			return
		sounds.stream = preload("res://audio/player/Hurt.wav")
		sounds.play()
		invincibility_time = 1.0
		
# debug
func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event.is_action_pressed("gm_debug"):
			if state == STATES.DEBUG:
				state = STATES.NORMAL
			elif state == STATES.NORMAL:
				state = STATES.DEBUG

func die() -> void:
	if state == STATES.DEBUG: return
	var expl = BIG_PUFF.instantiate()
	expl.global_position = global_position
	sounds.stream = preload("res://audio/player/Explosion.wav")
	sounds.play()
	add_sibling(expl)
	health.health = 0
	sounds.play()
	sprite.hide()
	set_physics_process(false)
	set_process(false)
	collision_layer = 0
	input_manager.locked = true
	GlobalMusic.stop()
	await get_tree().create_timer(2.0).timeout
	Dialogic.start("res://dialogic/general/game_over.dtl")
	# reset boss meter
	GlobalHud.meter = 0

func step_action() -> void:
	sounds.stream = preload("res://audio/player/Step.wav")
	sounds.play()

func interact_trigger(trigger: InteractTrigger) -> void:
	# check if one time and triggered already (or if there's already a timeline running)
	if trigger.one_time && trigger.was_triggered || Global.current_timeline:
		return
	# check if to skip dialogue
	if trigger.skip_on_dialogic_variable != "":
		var get_var = Global.convert_dialogic_string(trigger.skip_on_dialogic_variable)
		# verify the pulled variable is a boolean
		if get_var is bool:
			if get_var:
				return
		
	state = STATES.IDLE
	# reset player velocity if reset velocity is true (stops players from sliding around)
	if trigger.reset_velocity:
		velocity = Vector2.ZERO
	trigger.timeline_target.activate()
	trigger.interact_called(self)
	if trigger.unlock_after_sequence:
		await trigger.timeline_target.sequence_finished
		state = STATES.NORMAL
		animator.play("idle")
	trigger.was_triggered = true

func pause_handling() -> void:
	# check if we can pause
	if !locked && Global.current_timeline == null:
		PauseMenu.pause()

func update_weapon_display() -> void:
	if GlobalWeapons.weapon_index == GlobalWeapons.WEAPONS.NONE:
		# set to transparent so animations can toggle visibility
		$Sprite/Sprite/Weapon.modulate = Color.TRANSPARENT
	else:
		# reset visibility
		$Sprite/Sprite/Weapon.modulate = Color.WHITE
		$Sprite/Sprite/Weapon.frame = 10+GlobalWeapons.weapon_index

# handle shooting
func shoot_pressed() -> void:
	# check that the state node flag has firing enabled
	if !state_node.can_fire || !GlobalWeapons.weapon: return
	# check projectile limit
	if GlobalWeapons.weapon.projectile_limit <= projectile_table.size() && GlobalWeapons.weapon.projectile_limit != 0:
		return

	var rotated_fire:float = 0.0
	if input_manager.y_input < 0.0 || (input_manager.y_input > 0.0 && !is_on_floor()):
		rotated_fire += deg_to_rad(90.0)*input_manager.y_input
	
	match(GlobalWeapons.weapon_index):
		GlobalWeapons.WEAPONS.MACHINE:
			# push back in other direction if not on floor
			if (GlobalWeapons.weapon.ammo > 0 || GlobalWeapons.weapon.max_ammo <= 0) && !is_on_floor():
				velocity -= Vector2(20.0*direction,0.0).rotated(rotated_fire*direction)
			weapon_fire_action(rotated_fire)
		_: # default behaviour
			weapon_fire_action(rotated_fire)

func weapon_fire_action(rotated_fire:float = 0.0) -> void:
	# check that a projectile object exists
	if !GlobalWeapons.weapon.projectile: return
	# set the refill timer to the shoot refill delay (used for weapons that auto refill)
	GlobalWeapons.weapon.refill_timer = -GlobalWeapons.weapon.shoot_refill_delay
	# check that there's ammo (and that max ammo isn't 0)
	if GlobalWeapons.weapon.ammo <= 0 && GlobalWeapons.weapon.max_ammo > 0: return
	var proj:Projectile = GlobalWeapons.weapon.projectile.duplicate()
	proj.velocity = Vector2(proj.fire_speed*direction,0.0)
	
	weapon_sounds.stream = preload("res://audio/weapons/Fire.wav")
	weapon_sounds.play()
	
	# check if the particle animations have a matching animation name
	if %Particle.sprite_frames.has_animation(GlobalWeapons.weapon.projectile_fire_animation):
		%Particle.stop()
		%Particle.play(GlobalWeapons.weapon.projectile_fire_animation)
		%Particle.show()
	
	proj.global_position = fire_point.global_position
	proj.rotation = rotated_fire
	if proj.rotation == 0.0:
		proj.scale.x = direction
	proj.velocity = proj.velocity.rotated(rotated_fire*direction)
	proj.weapon_manager = self
	projectile_table.append(proj)
	add_sibling(proj)
	# decrease ammo
	if GlobalWeapons.weapon.max_ammo > 0:
		GlobalWeapons.weapon.ammo -= 1

# on room exit
func _exit_tree() -> void:
	# set the current health stats for memory (these values are synced in _ready)
	# check that max health isn't 0 (prevents carrying max health on reset)
	if max_health != 0:
		max_health = health.max_health
	
	if health.health <= 0:
		# reset health on room change if dead
		current_health = health.max_health
	else:
		current_health = health.health
