extends SequenceNode

# make the player stay in place after reloading
@export var save_player_position:bool = true

func activate() -> void:
	if save_player_position:
		var player:Player = get_tree().get_first_node_in_group("player")
		Player.go_to_spawn = true
		Player.spawn_point = player.global_position
	get_tree().reload_current_scene()
