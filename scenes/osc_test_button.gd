extends Button

func _on_pressed() -> void:
	OscClient.send_message("/roi/mouth", [0.5,0.0,0.55,1.0])
