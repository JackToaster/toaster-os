extends MeshInstance3D

func _process(delta: float) -> void:
	position.y += cos(Time.get_ticks_msec() * 0.003) * delta * 0.5
