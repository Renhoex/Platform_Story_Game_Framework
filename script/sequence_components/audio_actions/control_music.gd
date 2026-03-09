extends SequenceNode

enum MUSIC_ACTIONS {STOP, PLAY}
# if music is left blank it will just play whateversong is set in the music player
@export var music:AudioStream
@export var music_action:MUSIC_ACTIONS = MUSIC_ACTIONS.PLAY

func activate() -> void:
	if music:
		GlobalMusic.stream = music
	
	match(music_action):
		MUSIC_ACTIONS.STOP:
			GlobalMusic.stop()
		MUSIC_ACTIONS.PLAY:
			GlobalMusic.play()
