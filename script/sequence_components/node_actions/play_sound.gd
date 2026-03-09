extends SequenceNode

@export var sound:AudioStream
@export var audio_stream_target:AudioStreamPlayer

func activate() -> void:
	# check for an audio stream target (useful if you wanna set a specific sound location)
	if audio_stream_target:
		# check if there's an audio stream (having none will just play whatever the current stream already is
		if sound:
			audio_stream_target.stream = sound
		audio_stream_target.play()

	# do the same as above but as a global audio call
	if sound:
		GlobalAudio.stream = sound
	GlobalAudio.play()
