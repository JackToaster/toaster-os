extends Slider

@export
var path: String

func _process(_delta: float) -> void:
	var rx_val = OscServer.incoming_messages.get(path, [0])[0]
	value = lerp(min_value, max_value, rx_val)
