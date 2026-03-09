extends Node
@onready var boss: Boss = $".."

var timer:float = 0.0
const BIG_PUFF = preload("uid://bahac67suqrjr")

func physics_process(delta: float) -> void:
	timer += delta
	# bounce
	if boss.is_on_floor():
		boss.velocity = Vector2(float(boss.direction)*60.0,-125.0)
	if boss.is_on_wall():
		boss.direction = int(sign(boss.get_wall_normal().x))

func process(delta: float) -> void:
	$"../Sprite/BallGuyFace".position.x = lerp($"../Sprite/BallGuyFace".position.x,40.0*float(boss.direction),delta * 10.0)

func death_call() -> void:
	for i in range(32):
		var puff = BIG_PUFF.instantiate()
		boss.add_sibling(puff)
		puff.global_position = boss.global_position+Vector2(randf_range(-64,64),randf_range(-64,64))
		await get_tree().physics_frame
	# delete self
	boss.queue_free()
