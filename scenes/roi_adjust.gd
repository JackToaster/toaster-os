extends Control

@export
var step_size: float = 0.01

class RoiSide:
	var value
	var step
	func _init(_value, _step):
		value = _value
		step = _step
	func increment():
		value += step
		value = clamp(value, 0, 1)
	func decrement():
		value -= step
		value = clamp(value, 0, 1)

@onready var top = RoiSide.new(0.0, -step_size)
@onready var bottom = RoiSide.new(1.0, step_size)
@onready var left = RoiSide.new(0.0, -step_size)
@onready var right = RoiSide.new(1.0, step_size)

func connect_plus_minus_buttons(btn: Control, roi_side: RoiSide):
	var plus_btn: Button = btn.get_node("Plus")
	var minus_btn: Button = btn.get_node("Minus")
	
	plus_btn.pressed.connect(roi_side.increment)
	minus_btn.pressed.connect(roi_side.decrement)
	
	plus_btn.pressed.connect(send_roi)
	minus_btn.pressed.connect(send_roi)
	

func send_roi():
	var img_ref_size = $ImageRef.size
	var x_scale = right.value - left.value
	var x_offs = left.value
	
	var y_scale = bottom.value - top.value
	var y_offs = top.value
	
	$ImageRef/RoiRef.set_size(Vector2(x_scale, y_scale) * img_ref_size)
	$ImageRef/RoiRef.set_position(Vector2(x_offs, y_offs) * img_ref_size)
	
	$OSCMessage.send_message([left.value,top.value,right.value,bottom.value])

func _ready() -> void:
	connect_plus_minus_buttons($Top, top)
	connect_plus_minus_buttons($Bottom, bottom)
	connect_plus_minus_buttons($Left, left)
	connect_plus_minus_buttons($Right, right)
