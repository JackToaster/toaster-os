extends Node

@export
var sliders: Array[HSlider]

func _process(delta: float) -> void:
	var offs = 0
	for slider in sliders:
		var pos: float = lerp(slider.min_value, slider.max_value, 
			sin(offs + 0.002 * Time.get_ticks_msec()) * 0.5 + 0.5
		)
		slider.value = pos
		offs += 1
