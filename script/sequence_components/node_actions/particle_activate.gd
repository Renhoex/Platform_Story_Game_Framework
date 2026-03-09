extends SequenceNode

@export var cpu_particles:Array[CPUParticles2D] = []
@export var gpu_particles:Array[GPUParticles2D] = []

# activate particles
func activate() -> void:
	for i in cpu_particles:
		i.emitting = true
	for i in gpu_particles:
		i.emitting = true
