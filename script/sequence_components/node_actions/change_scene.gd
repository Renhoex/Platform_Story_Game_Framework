extends SequenceNode

@export var connected_sequence_name:String
@export_file_path("*.tscn") var scene_file


# teleport the node
func activate() -> void:
	if scene_file:
		get_tree().change_scene_to_file(scene_file)
		Global.sequence_call = connected_sequence_name
