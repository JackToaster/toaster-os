extends Control
@export var osc_parameters: Array[String]


var slider_map = {}

func _ready() -> void:
	var base_slider = $"VBoxContainer/labeled slider"
	$VBoxContainer.remove_child(base_slider)
	
	for param in osc_parameters:
		var slider = base_slider.duplicate()
		slider.name = param
		slider.title = param.lstrip("/")
		slider_map.set(param, slider)
		$VBoxContainer.add_child(slider)

func _process(_delta: float) -> void:
	for param in osc_parameters:
		slider_map[param].value = OscServer.incoming_messages.get(param, [0])[0]
