extends HBoxContainer

@export var value: float:
	set(value):
		$HSlider.value = $HSlider.max_value * value

@export var title: String:
	set(value):
		$Label.text = value
