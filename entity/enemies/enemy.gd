class_name Enemy extends CharacterBody2D

@export var sprite: CanvasGroup
@export var spawn_on_death: PackedScene = preload("uid://d0vbfsam5masf")
const ITEM = preload("uid://ghuwmy12hgax")
var player:Player = null
var player_list:Array[Player] = []
@export_range(-1.0,1.0,2.0) var direction:int = -1:
	get():
		return int(remap(max(0,sign(direction)),0,1,-1,1))

func _ready() -> void:
	for i in get_tree().get_nodes_in_group("player"):
		if i is Player:
			player_list.append(i)

# called when the enemy dies, called from the health component
func _on_health_component_dead() -> void:
	var item = ITEM.instantiate()
	# call deferred to avoid debug errors
	call_deferred("add_sibling",item)
	item.call_deferred("determine_item")
	# set to current position
	item.global_position = global_position
	# set life time
	item.life_time = 15.0
	
	#check that a scene for spawn on death exists
	if spawn_on_death:
		var spawn = spawn_on_death.instantiate()
		call_deferred("add_sibling",spawn)
		spawn.global_position = global_position
	
	queue_free()

func _on_damaged() -> void:
	if sprite:
		sprite.self_modulate = Color(2.454, 2.454, 2.454, 1.0)
		await get_tree().physics_frame
		await get_tree().physics_frame
		sprite.self_modulate = Color.WHITE

func get_player() -> Player:
	for i in player_list:
		if !player:
			player = i
		elif player.global_position.distance_to(global_position) > i.global_position.distance_to(global_position):
			player = i
	return player
