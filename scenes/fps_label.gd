extends Label

func _process(delta: float) -> void:
	set_text("%d FPS" % Engine.get_frames_per_second())
