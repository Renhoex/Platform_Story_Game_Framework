extends Node2D

@export var stage_song:AudioStream
@export var room_start_target:TimeLineHandler

func _ready() -> void:
	# handle music
	if GlobalMusic.stream != stage_song || !GlobalMusic.playing:
		GlobalMusic.stream = stage_song
		GlobalMusic.play()
	# activate any connected time line handlers
	if room_start_target:
		room_start_target.activate()
