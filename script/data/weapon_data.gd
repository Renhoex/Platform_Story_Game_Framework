class_name Weapon extends Node

@export_category("Textures")
@export var icon = preload("res://graphics/item_icons/weapons/Standard.png")
@export var item_icon = preload("res://graphics/item_icons/weapons/StandardIcon.png")
@export_category("Projectile Settings")
@export var max_ammo:int = 50: # setting to 0 will be infinite
	set(value):
		max_ammo = value
		# update HUD if the current weapon is equippred
		if GlobalWeapons:
			if GlobalWeapons.weapon == self:
				GlobalHud.update_weapon_info()
var ammo:int = 50:
	get():
		return min(max_ammo,ammo)
	set(value):
		ammo = min(max_ammo,value)
		# update HUD if the current weapon is equippred
		if GlobalWeapons:
			if GlobalWeapons.weapon == self:
				GlobalHud.update_weapon_info()
@export var projectile:Projectile
@export var projectile_limit:int = 0
# auto filling
@export var refill_rate:float = 0.0
@export var shoot_refill_delay:float = 0.0

@export var projectile_fire_animation:String = ""
@export_category("Items settings")
@export var collected:bool = false
@export var label:String = ""
@export var auto_fire_rate:float = 0.0

var refill_timer:float = 0.0

static var weapon_keys:Dictionary[String, Weapon] = {}

# filled up using RESET_VALUES in ready
var default_values:Dictionary[String, Variant] = {}
# add string values for any settings you'd wanna reset on a game restart
const RESET_VALUES:PackedStringArray = [
"ammo",
"max_ammo",
"projectile",
"projectile_limit",
"collected",
"refill_timer",
]

func _ready() -> void:
	# assign weapon keys to set (static value that can be accessed from the class name)
	# fastest way to do a lookup by string
	weapon_keys[name] = self
	
	# fill up the default values for resetting
	for i:String in RESET_VALUES:
		# check value is in self
		if i in self:
			default_values[i] = get(i)
		else:
			print("ERROR: value not found - "+i)

func _physics_process(delta: float) -> void:
	# check that we're the active weapon
	if GlobalWeapons.weapon != self: return
	# refill weapons
	if refill_rate > 0.0:
		if ammo < max_ammo:
			refill_timer += delta
			# decrease refill timer using a while statement incase the it goes over the refill rate
			# if over the refill rate add ammo
			while refill_timer > refill_rate:
				refill_timer -= refill_rate
				ammo += 1

func reset_to_default() -> void:
	# loop through default values, if they exist then set the matching variables to them
	for i in default_values.keys():
		# check that value exists in default and self
		if i in self && default_values.has(i):
			set(i,default_values[i])
		else:
			print("ERROR: value not found - "+i)
