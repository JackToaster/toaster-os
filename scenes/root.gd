extends Node2D

func _enter_tree() -> void:
	get_window().position = Vector2i(0,0)
	print("Window position:")
	print($HeadRender.get_window_offset())
