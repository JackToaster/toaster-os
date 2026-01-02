extends HBoxContainer

@export var step:float = 0.1

signal changed(value: float)

func _ready() -> void:
	$brighter.connect("pressed", _brighter_pressed)
	$dimmer.connect("pressed", _dimmer_pressed)
	call_deferred("_initial_signal")

func _initial_signal():
	changed.emit($HSlider.value)

func _brighter_pressed():
	$HSlider.value += step
	changed.emit($HSlider.value)


func _dimmer_pressed():
	$HSlider.value -= step
	changed.emit($HSlider.value)
