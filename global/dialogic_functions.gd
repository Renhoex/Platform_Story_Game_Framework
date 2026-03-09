extends Node
# used for general actions that should be called specifically in dialogic (mostly for organizing)
# global.gd can be used for functions that can be used in different scripts

func stop_global_music() -> void:
	GlobalMusic.stop()

func play_global_music() -> void:
	GlobalMusic.play()

func set_health_preview() -> void:
	GlobalHud.item_texture.texture = preload("res://graphics/item_icons/HeartContainer.png")
